// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Maestro.Common.AzureDevOpsTokens;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;
using Microsoft.TeamFoundation.SourceControl.WebApi;
using Microsoft.VisualStudio.Services.Common;
using Microsoft.VisualStudio.Services.WebApi;
using Newtonsoft.Json.Linq;

namespace Microsoft.DotNet.DarcLib;

public class AzureDevOpsBaseClient : RemoteRepoBase
{
    private const string DefaultApiVersion = "5.0";

    protected const string RefsHeadsPrefix = "refs/heads/";

    private const int MaxPullRequestDescriptionLength = 4000;

    private static readonly string AzureDevOpsHostPattern = @"dev\.azure\.com\";

    private static readonly Regex RepositoryUriPattern = new(
        $"^https://{AzureDevOpsHostPattern}/(?<account>[a-zA-Z0-9]+)/(?<project>[a-zA-Z0-9-]+)/_git/(?<repo>[a-zA-Z0-9-\\.]+)");

    private static readonly Regex PullRequestApiUriPattern = new(
        $"^https://{AzureDevOpsHostPattern}/(?<account>[a-zA-Z0-9]+)/(?<project>[a-zA-Z0-9-]+)/_apis/git/repositories/(?<repo>[a-zA-Z0-9-\\.]+)/pullRequests/(?<id>\\d+)");

    private static readonly Regex LegacyRepositoryUriPattern = new(
        @"^https://(?<account>[a-zA-Z0-9]+)\.visualstudio\.com/(?<project>[a-zA-Z0-9-]+)/_git/(?<repo>[a-zA-Z0-9-\.]+)");

    private readonly IAzureDevOpsTokenProvider _tokenProvider;
    private readonly ILogger _logger;

    public AzureDevOpsBaseClient(IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryPath)
        : base(tokenProvider, processManager, temporaryPath, null, logger)
    {
        _tokenProvider = tokenProvider;
        _logger = logger;
    }

    public bool AllowRetries { get; set; } = true;

    public async Task MergeDependencyPullRequestAsync(string pullRequestUrl, MergePullRequestParameters parameters,
        string mergeCommitMessage)
    {
        (string accountName, string projectName, string repoName, int id) = ParsePullRequestUri(pullRequestUrl);

        using VssConnection connection = CreateVssConnection(accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();
        var pullRequest = await client.GetPullRequestAsync(repoName, id, includeCommits: true);

        await client.UpdatePullRequestAsync(
            new GitPullRequest
            {
                Status = PullRequestStatus.Completed,
                CompletionOptions = new GitPullRequestCompletionOptions
                {
                    MergeCommitMessage = mergeCommitMessage,
                    BypassPolicy = true,
                    BypassReason = "All required checks were successful",
                    SquashMerge = parameters.SquashMerge,
                    DeleteSourceBranch = parameters.DeleteSourceBranch
                },
                LastMergeSourceCommit = new GitCommitRef
                { CommitId = pullRequest.LastMergeSourceCommit.CommitId, Comment = mergeCommitMessage }
            },
            projectName,
            repoName,
            id);
    }

    /// <summary>
    /// Get the status of a pull request
    /// </summary>
    /// <param name="pullRequestUrl">URI of pull request</param>
    /// <returns>Pull request status</returns>
    public async Task<PrStatus> GetPullRequestStatusAsync(string pullRequestUrl)
    {
        (string accountName, string projectName, string repoName, int id) = ParsePullRequestUri(pullRequestUrl);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get, accountName, projectName, $"_apis/git/repositories/{repoName}/pullRequests/{id}", _logger);

        if (Enum.TryParse(content["status"].ToString(), true, out AzureDevOpsPrStatus status))
        {
            if (status == AzureDevOpsPrStatus.Active)
            {
                return PrStatus.Open;
            }

            if (status == AzureDevOpsPrStatus.Completed)
            {
                return PrStatus.Merged;
            }

            if (status == AzureDevOpsPrStatus.Abandoned)
            {
                return PrStatus.Closed;
            }

            throw new DarcException($"Unhandled Azure DevOPs PR status {status}");
        }

        throw new DarcException($"Failed to parse PR status: {content["status"]}");
    }

    /// <summary>
    ///     Retrieve information on a specific pull request
    /// </summary>
    /// <param name="pullRequestUrl">Uri of the pull request</param>
    /// <returns>Information on the pull request.</returns>
    public async Task<PullRequest> GetPullRequestAsync(string pullRequestUrl)
    {
        (string accountName, string projectName, string repoName, int id) = ParsePullRequestUri(pullRequestUrl);

        using VssConnection connection = CreateVssConnection(accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();

        GitPullRequest pr = await client.GetPullRequestAsync(projectName, repoName, id);
        // Strip out the refs/heads prefix on BaseBranch and HeadBranch because almost
        // all of the other APIs we use do not support them (e.g. get an item at branch X).
        // At the time this code was written, the API always returned the refs with this prefix,
        // so verify this is the case.

        if (!pr.TargetRefName.StartsWith(RefsHeadsPrefix) || !pr.SourceRefName.StartsWith(RefsHeadsPrefix))
        {
            throw new NotImplementedException("Expected that source and target ref names returned from pull request API include refs/heads");
        }

        return new PullRequest
        {
            Title = pr.Title,
            Description = pr.Description,
            BaseBranch = pr.TargetRefName.Substring(RefsHeadsPrefix.Length),
            HeadBranch = pr.SourceRefName.Substring(RefsHeadsPrefix.Length),
        };
    }

    /// <summary>
    ///     Update a pull request with new information
    /// </summary>
    /// <param name="pullRequestUri">Uri of pull request to update</param>
    /// <param name="pullRequest">Pull request info to update</param>
    /// <returns></returns>
    public async Task UpdatePullRequestAsync(string pullRequestUri, PullRequest pullRequest)
    {
        (string accountName, string projectName, string repoName, int id) = ParsePullRequestUri(pullRequestUri);

        using VssConnection connection = CreateVssConnection(accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();

        await client.UpdatePullRequestAsync(
            new GitPullRequest
            {
                Title = pullRequest.Title,
                Description = TruncateDescriptionIfNeeded(pullRequest.Description),
            },
            projectName,
            repoName,
            id);
    }

    /// <summary>
    ///     Execute a command on the remote repository.
    /// </summary>
    /// <param name="method">Http method</param>
    /// <param name="accountName">Azure DevOps account name</param>
    /// <param name="projectName">Project name</param>
    /// <param name="requestPath">Path for request</param>
    /// <param name="logger">Logger</param>
    /// <param name="body">Optional body if <paramref name="method"/> is Put or Post</param>
    /// <param name="versionOverride">API version override</param>
    /// <param name="baseAddressSubpath">[baseAddressSubPath]dev.azure.com subdomain to make the request</param>
    /// <param name="retryCount">Maximum number of tries to attempt the API request</param>
    /// <returns>Http response</returns>
    public async Task<JObject> ExecuteAzureDevOpsAPIRequestAsync(
        HttpMethod method,
        string accountName,
        string projectName,
        string requestPath,
        ILogger logger,
        string body = null,
        string versionOverride = null,
        bool logFailure = true,
        string baseAddressSubpath = null,
        int retryCount = 15)
    {
        if (!AllowRetries)
        {
            retryCount = 0;
        }
        using (HttpClient client = CreateHttpClient(accountName, projectName, versionOverride, baseAddressSubpath))
        {
            var requestManager = new HttpRequestManager(client,
                method,
                requestPath,
                logger,
                body,
                versionOverride,
                logFailure);
            using (var response = await requestManager.ExecuteAsync(retryCount))
            {
                string responseContent = response.StatusCode == HttpStatusCode.NoContent ?
                    "{}" :
                    await response.Content.ReadAsStringAsync();

                return JObject.Parse(responseContent);
            }
        }
    }

    /// <summary>
    /// Create a connection to AzureDevOps using the VSS APIs
    /// </summary>
    /// <param name="accountName">Uri of repository or pull request</param>
    /// <returns>New VssConnection</returns>
    protected VssConnection CreateVssConnection(string accountName)
    {
        var accountUri = new Uri($"https://dev.azure.com/{accountName}");
        var creds = new VssCredentials(new VssBasicCredential("", _tokenProvider.GetTokenForAccount(accountName)));
        return new VssConnection(accountUri, creds);
    }

    /// <summary>
    /// Create a new http client for talking to the specified azdo account name and project.
    /// </summary>
    /// <param name="versionOverride">Optional version override for the targeted API version.</param>
    /// <param name="baseAddressSubpath">Optional subdomain for the base address for the API. Should include the final dot.</param>
    /// <param name="accountName">Azure DevOps account</param>
    /// <param name="projectName">Azure DevOps project</param>
    /// <returns>New http client</returns>
    private HttpClient CreateHttpClient(string accountName, string projectName = null, string versionOverride = null, string baseAddressSubpath = null)
    {
        baseAddressSubpath = EnsureEndsWith(baseAddressSubpath, '.');

        string address = $"https://{baseAddressSubpath}dev.azure.com/{accountName}/";
        if (!string.IsNullOrEmpty(projectName))
        {
            address += $"{projectName}/";
        }

        var client = new HttpClient(new HttpClientHandler { CheckCertificateRevocationList = true })
        {
            BaseAddress = new Uri(address)
        };

        client.DefaultRequestHeaders.Add(
            "Accept",
            $"application/json;api-version={versionOverride ?? DefaultApiVersion}");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Basic",
            Convert.ToBase64String(Encoding.ASCII.GetBytes(string.Format("{0}:{1}", "", _tokenProvider.GetTokenForAccount(accountName)))));

        return client;
    }

    /// <summary>
    ///     Ensure that the input string ends with 'shouldEndWith' char. 
    ///     Returns null if input parameter is null.
    /// </summary>
    /// <param name="input">String that must have 'shouldEndWith' at the end.</param>
    /// <param name="shouldEndWith">Character that must be present at end of 'input' string.</param>
    /// <returns>Input string appended with 'shouldEndWith'</returns>
    private static string EnsureEndsWith(string input, char shouldEndWith)
    {
        if (input == null) return null;

        return input.TrimEnd(shouldEndWith) + shouldEndWith;
    }

    /// <summary>
    /// Parse a repository url into its component parts
    /// </summary>
    /// <param name="repoUri">Repository url to parse</param>
    /// <returns>Tuple of account, project, repo, and pr id</returns>
    public static (string accountName, string projectName, string repoName, int id) ParsePullRequestUri(string prUri)
    {
        Match m = PullRequestApiUriPattern.Match(prUri);
        if (!m.Success)
        {
            throw new ArgumentException(
                @"Pull request URI should be in the form  https://dev.azure.com/:account/:project/_apis/git/repositories/:repo/pullRequests/:id");
        }

        return (m.Groups["account"].Value,
            m.Groups["project"].Value,
            m.Groups["repo"].Value,
            int.Parse(m.Groups["id"].Value));
    }

    /// <summary>
    /// Parse a repository url into its component parts.
    /// </summary>
    /// <param name="repoUri">Repository url to parse</param>
    /// <returns>Tuple of account, project, repo</returns>
    /// <remarks>
    ///     While we really only want to support dev.azure.com, in some cases
    ///     builds are still being reported from foo.visualstudio.com. This is apparently because
    ///     the url the agent connects to is what determines this property. So for now, support both forms.
    ///     We don't need to support this for PR urls because the repository target urls in the Maestro
    ///     database are restricted to dev.azure.com forms.
    /// </remarks>
    public static (string accountName, string projectName, string repoName) ParseRepoUri(string repoUri)
    {
        repoUri = NormalizeUrl(repoUri);

        Match m = RepositoryUriPattern.Match(repoUri);
        if (!m.Success)
        {
            m = LegacyRepositoryUriPattern.Match(repoUri);
            if (!m.Success)
            {
                throw new ArgumentException(
                    "Repository URI should be in the form https://dev.azure.com/:account/:project/_git/:repo or " +
                    "https://:account.visualstudio.com/:project/_git/:repo");
            }
        }

        return (m.Groups["account"].Value,
            m.Groups["project"].Value,
            m.Groups["repo"].Value);
    }

    /// <summary>
    // If repoUri includes the user in the account we remove it from URIs like
    // https://dnceng@dev.azure.com/dnceng/internal/_git/repo
    // If the URL host is of the form "dnceng.visualstudio.com" like
    // https://dnceng.visualstudio.com/internal/_git/repo we replace it to "dev.azure.com/dnceng"
    // for consistency
    /// </summary>
    /// <param name="url">The original url</param>
    /// <returns>Transformed url</returns>
    public static string NormalizeUrl(string repoUri)
    {
        if (Uri.TryCreate(repoUri, UriKind.Absolute, out Uri parsedUri))
        {
            if (!string.IsNullOrEmpty(parsedUri.UserInfo))
            {
                repoUri = repoUri.Replace($"{parsedUri.UserInfo}@", string.Empty);
            }

            Match m = LegacyRepositoryUriPattern.Match(repoUri);

            if (m.Success)
            {
                string replacementUri = $"{Regex.Unescape(AzureDevOpsHostPattern)}/{m.Groups["account"].Value}";
                repoUri = repoUri.Replace(parsedUri.Host, replacementUri);
            }
        }

        return repoUri;
    }

    /// <summary>
    /// Helper function for truncating strings to a set length.
    ///  See https://github.com/dotnet/arcade/issues/5811 
    /// </summary>
    /// <param name="str">String to be shortened if necessary</param>
    /// <returns></returns>
    protected static string TruncateDescriptionIfNeeded(string str)
    {
        if (str.Length > MaxPullRequestDescriptionLength)
        {
            return str.Substring(0, MaxPullRequestDescriptionLength);
        }
        return str;
    }
}
