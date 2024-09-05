// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Maestro.Common.AzureDevOpsTokens;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.DotNet.DarcLib.Models.AzureDevOps;
using Microsoft.Extensions.Logging;
using Microsoft.TeamFoundation.SourceControl.WebApi;
using Microsoft.VisualStudio.Services.WebApi;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Microsoft.DotNet.DarcLib;

public interface IAzureDevOpsProjectClient : IAzureDevOpsAccountClient
{
    Task DeleteFeedAsync(string feedIdentifier);
    Task<AzureDevOpsFeed> GetFeedAndPackagesAsync(string feedIdentifier);
    Task<AzureDevOpsFeed> GetFeedAsync(string feedIdentifier);
    Task<List<AzureDevOpsFeed>> GetFeedsAndPackagesAsync();
    Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier);
    Task<string> GetProjectIdAsync();
    Task<IList<Check>> GetPullRequestChecksAsync(string pullRequestUrl);
    Task<AzureDevOpsRelease> GetReleaseAsync(string accountName, string projectName, int releaseId);
    Task<int> StartNewBuildAsync(int azdoDefinitionId, string sourceBranch, string sourceVersion, Dictionary<string, string> queueTimeVariables = null, Dictionary<string, string> templateParameters = null, Dictionary<string, string> pipelineResources = null);


    /// <summary>
    ///   Deletes a NuGet package version from a feed.
    /// </summary>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <param name="packageName">Name of the package</param>
    /// <param name="version">Version to delete</param>
    /// <returns>Async task</returns>
    Task DeleteNuGetPackageVersionFromFeedAsync(string feedIdentifier, string packageName, string version);

    /// <summary>
    ///   Fetches an specific AzDO build based on its ID.
    /// </summary>
    /// <param name="buildId">Id of the build to be retrieved</param>
    /// <returns>AzureDevOpsBuild</returns>
    Task<AzureDevOpsBuild> GetBuildAsync(long buildId);

    /// <summary>
    ///   Fetches artifacts belonging to a given AzDO build.
    /// </summary>
    /// <param name="buildId">Id of the build to be retrieved</param>
    /// <returns>List of build artifacts</returns>
    Task<List<AzureDevOpsBuildArtifact>> GetBuildArtifactsAsync(int buildId, int maxRetries = 15);

    /// <summary>
    ///   Fetches a list of last run AzDO builds for a given build definition.
    /// </summary>
    /// <param name="definitionId">Id of the pipeline (build definition)</param>
    /// <param name="branch">Filter by branch</param>
    /// <param name="count">Number of builds to retrieve</param>
    /// <param name="status">Filter by status</param>
    Task<JObject> GetBuildsAsync(int definitionId, string branch, int count, string status);
}

public class AzureDevOpsProjectClient : AzureDevOpsAccountClient, IAzureDevOpsProjectClient
{
    private readonly string _accountName;
    private readonly string _projectName;
    private readonly ILogger _logger;

    public AzureDevOpsProjectClient(string accountName, string projectName, IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryPath)
        : base(accountName, tokenProvider, processManager, logger, temporaryPath)
    {
        _accountName = accountName;
        _projectName = projectName;
        _logger = logger;
    }

    /// <summary>
    ///   Gets the list of Build Artifacts names.
    /// </summary>
    /// <returns>List of Azure DevOps build artifacts names.</returns>
    public async Task<List<AzureDevOpsBuildArtifact>> GetBuildArtifactsAsync(int azureDevOpsBuildId, int maxRetries = 15)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            $"_apis/build/builds/{azureDevOpsBuildId}/artifacts",
            _logger,
            versionOverride: "5.0",
            retryCount: maxRetries);

        return ((JArray)content["value"]).ToObject<List<AzureDevOpsBuildArtifact>>();
    }

    /// <summary>
    ///   Deletes a NuGet package version from a feed.
    /// </summary>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <param name="packageName">Name of the package</param>
    /// <param name="version">Version to delete</param>
    /// <returns>Async task</returns>
    public async Task DeleteNuGetPackageVersionFromFeedAsync(string feedIdentifier, string packageName, string version)
    {
        await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Delete,
            $"_apis/packaging/feeds/{feedIdentifier}/nuget/packages/{packageName}/versions/{version}",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "pkgs.");
    }

    /// <summary>
    ///   Fetches a list of last run AzDO builds for a given build definition.
    /// </summary>
    /// <param name="definitionId">Id of the pipeline (build definition)</param>
    /// <param name="branch">Filter by branch</param>
    /// <param name="count">Number of builds to retrieve</param>
    /// <param name="status">Filter by status</param>
    /// <returns>AzureDevOpsBuild</returns>
    public async Task<JObject> GetBuildsAsync(int definitionId, string branch, int count, string status)
        => await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            $"_apis/build/builds?definitions={definitionId}&branchName={branch}&statusFilter={status}&$top={count}",
            _logger,
            versionOverride: "5.0");

    /// <summary>
    ///   Fetches an specific AzDO build based on its ID.
    /// </summary>
    /// <param name="buildId">Id of the build to be retrieved</param>
    /// <returns>AzureDevOpsBuild</returns>
    public async Task<AzureDevOpsBuild> GetBuildAsync(long buildId)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            $"_apis/build/builds/{buildId}",
            _logger,
            versionOverride: "5.0");

        return content.ToObject<AzureDevOpsBuild>();
    }

    /// <summary>
    ///   Gets all Artifact feeds along with their packages in an Azure DevOps account.
    /// </summary>
    /// <returns>List of Azure DevOps feeds in the account.</returns>
    public async Task<List<AzureDevOpsFeed>> GetFeedsAndPackagesAsync()
    {
        var feeds = await GetFeedsAsync();
        feeds.ForEach(async feed => feed.Packages = await GetPackagesForFeedAsync(feed.Project?.Name, feed.Name));
        return feeds;
    }

    /// <summary>
    ///   Gets a specified Artifact feed in an Azure DevOps account.
    /// </summary>
    /// <param name="feedIdentifier">ID or name of the feed</param>
    /// <returns>List of Azure DevOps feeds in the account</returns>
    public async Task<AzureDevOpsFeed> GetFeedAsync(string feedIdentifier)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            $"_apis/packaging/feeds/{feedIdentifier}",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "feeds.");

        AzureDevOpsFeed feed = content.ToObject<AzureDevOpsFeed>();
        feed.Account = _accountName;
        return feed;
    }

    /// <summary>
    ///   Gets a specified Artifact feed with their pacckages in an Azure DevOps account.
    /// </summary>
    /// <param name="feedIdentifier">ID or name of the feed.</param>
    /// <returns>List of Azure DevOps feeds in the account.</returns>
    public async Task<AzureDevOpsFeed> GetFeedAndPackagesAsync(string feedIdentifier)
    {
        var feed = await GetFeedAsync(feedIdentifier);
        feed.Packages = await GetPackagesForFeedAsync(feedIdentifier, feed.Project.Name);

        return feed;
    }

    /// <summary>
    /// Gets all packages in a given Azure DevOps feed
    /// </summary>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <returns>List of packages in the feed</returns>
    public async Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            $"_apis/packaging/feeds/{feedIdentifier}/packages?includeAllVersions=true&includeDeleted=true",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "feeds.");

        return ((JArray)content["value"]).ToObject<List<AzureDevOpsPackage>>();
    }

    /// <summary>
    ///   Returns the project ID for a combination of Azure DevOps account and project name
    /// </summary>
    /// <returns>Project Id</returns>
    public async Task<string> GetProjectIdAsync()
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            null,
            $"_apis/projects/{_projectName}",
            _logger,
            versionOverride: "5.0");
        return content["id"].ToString();
    }

    /// <summary>
    /// Retrieve the list of status checks on a PR.
    /// </summary>
    /// <param name="pullRequestUrl">Uri of pull request</param>
    /// <returns>List of status checks.</returns>
    public async Task<IList<Check>> GetPullRequestChecksAsync(string pullRequestUrl)
    {
        (string accountName, string projectName, _, int id) = ParsePullRequestUri(pullRequestUrl);

        string projectId = await GetProjectIdAsync();

        string artifactId = $"vstfs:///CodeReview/CodeReviewId/{projectId}/{id}";

        string statusesPath = $"_apis/policy/evaluations?artifactId={artifactId}";

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(HttpMethod.Get,
            accountName,
            projectName,
            statusesPath,
            _logger,
            versionOverride: "5.1-preview.1");

        var values = JArray.Parse(content["value"].ToString());

        IList<Check> statuses = new List<Check>();
        foreach (JToken status in values)
        {
            bool isEnabled = status["configuration"]["isEnabled"].Value<bool>();

            if (isEnabled && Enum.TryParse(status["status"].ToString(), true, out AzureDevOpsCheckState state))
            {
                var checkState = state switch
                {
                    AzureDevOpsCheckState.Broken => CheckState.Error,
                    AzureDevOpsCheckState.Rejected => CheckState.Failure,
                    AzureDevOpsCheckState.Queued or AzureDevOpsCheckState.Running => CheckState.Pending,
                    AzureDevOpsCheckState.Approved => CheckState.Success,
                    _ => CheckState.None,
                };
                statuses.Add(
                    new Check(
                        checkState,
                        status["configuration"]["type"]["displayName"].ToString(),
                        status["configuration"]["url"].ToString()));
            }
        }

        return statuses;
    }

    /// <summary>
    /// Gets all the commits related to the pull request
    /// </summary>
    /// <param name="pullRequestUrl"></param>
    /// <returns>All the commits related to the pull request</returns>
    public async Task<IList<Commit>> GetPullRequestCommitsAsync(string pullRequestUrl)
    {
        (string accountName, _, string repoName, int id) = ParsePullRequestUri(pullRequestUrl);
        using VssConnection connection = CreateVssConnection(accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();

        var pullRequest = await client.GetPullRequestAsync(repoName, id, includeCommits: true);
        IList<Commit> commits = new List<Commit>(pullRequest.Commits.Length);
        foreach (var commit in pullRequest.Commits)
        {
            commits.Add(new Commit(
                commit.Author.Name == "DotNet-Bot" ? Constants.DarcBotName : commit.Author.Name,
                commit.CommitId,
                commit.Comment));
        }

        return commits;
    }

    /// <summary>
    ///   Deletes an Azure Artifacts feed and all of its packages
    /// </summary>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <returns>Async task</returns>
    public async Task DeleteFeedAsync(string feedIdentifier)
    {
        await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Delete,
            $"_apis/packaging/feeds/{feedIdentifier}",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "feeds.");
    }

    /// <summary>
    ///     Queue a new build on the specified build definition with the given queue time variables.
    /// </summary>
    /// <param name="azdoDefinitionId">ID of the build definition where a build should be queued.</param>
    /// <param name="queueTimeVariables">Queue time variables as a Dictionary of (variable name, value).</param>
    /// <param name="templateParameters">Template parameters as a Dictionary of (variable name, value).</param>
    /// <param name="pipelineResources">Pipeline resources as a Dictionary of (pipeline resource name, build number).</param>
    public async Task<int> StartNewBuildAsync(
        int azdoDefinitionId,
        string sourceBranch,
        string sourceVersion,
        Dictionary<string, string> queueTimeVariables = null,
        Dictionary<string, string> templateParameters = null,
        Dictionary<string, string> pipelineResources = null)
    {
        var variables = queueTimeVariables?
            .ToDictionary(x => x.Key, x => new AzureDevOpsVariable(x.Value))
            ?? [];

        var pipelineResourceParameters = pipelineResources?
            .ToDictionary(x => x.Key, x => new AzureDevOpsPipelineResourceParameter(x.Value))
            ?? [];

        var repositoryBranch = sourceBranch.StartsWith(RefsHeadsPrefix) ? sourceBranch : RefsHeadsPrefix + sourceBranch;

        var body = new AzureDevOpsPipelineRunDefinition
        {
            Resources = new AzureDevOpsRunResourcesParameters
            {
                Repositories = new Dictionary<string, AzureDevOpsRepositoryResourceParameter>
                {
                    { "self", new AzureDevOpsRepositoryResourceParameter(repositoryBranch, sourceVersion) }
                },
                Pipelines = pipelineResourceParameters
            },
            TemplateParameters = templateParameters,
            Variables = variables
        };

        string bodyAsString = JsonConvert.SerializeObject(body, Formatting.Indented);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Post,
            $"_apis/pipelines/{azdoDefinitionId}/runs",
            _logger,
            bodyAsString,
            versionOverride: "6.0-preview.1");

        return content.GetValue("id").ToObject<int>();
    }

    /// <summary>
    ///   Return the description of the release with ID informed.
    /// </summary>
    /// <param name="accountName">Azure DevOps account name</param>
    /// <param name="projectName">Project name</param>
    /// <param name="releaseId">ID of the release that should be looked up for</param>
    /// <returns>AzureDevOpsRelease</returns>
    public async Task<AzureDevOpsRelease> GetReleaseAsync(string accountName, string projectName, int releaseId)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            accountName,
            projectName,
            $"_apis/release/releases/{releaseId}",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "vsrm.");

        return content.ToObject<AzureDevOpsRelease>();
    }

    /// <summary>
    ///     Execute a command on the remote repository.
    /// </summary>
    /// <param name="method">Http method</param>
    /// <param name="requestPath">Path for request</param>
    /// <param name="logger">Logger</param>
    /// <param name="body">Optional body if <paramref name="method"/> is Put or Post</param>
    /// <param name="versionOverride">API version override</param>
    /// <param name="baseAddressSubpath">[baseAddressSubPath]dev.azure.com subdomain to make the request</param>
    /// <param name="retryCount">Maximum number of tries to attempt the API request</param>
    /// <returns>Http response</returns>
    protected Task<JObject> ExecuteAzureDevOpsAPIRequestAsync(
        HttpMethod method,
        string requestPath,
        ILogger logger,
        string body = null,
        string versionOverride = null,
        bool logFailure = true,
        string baseAddressSubpath = null,
        int retryCount = 15) => ExecuteAzureDevOpsAPIRequestAsync(
            method,
            _accountName,
            _projectName,
            requestPath,
            logger,
            body,
            versionOverride,
            logFailure,
            baseAddressSubpath,
            retryCount);
}
