// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Maestro.Common.AzureDevOpsTokens;
using Maestro.MergePolicyEvaluation;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.DotNet.Services.Utility;
using Microsoft.Extensions.Logging;
using Microsoft.TeamFoundation.SourceControl.WebApi;
using Microsoft.VisualStudio.Services.WebApi;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Serialization;

namespace Microsoft.DotNet.DarcLib;

public class AzureDevOpsClient : AzureDevOpsProjectClient, IRemoteGitRepo, IAzureDevOpsClient
{
    private static readonly string CommentMarker =
        "\n\n[//]: # (This identifies this comment as a Maestro++ comment)\n";

    // Azure DevOps uses this id when creating a new branch as well as when deleting a branch
    private static readonly string BaseObjectId = "0000000000000000000000000000000000000000";

    private static readonly List<string> VersionTypes = ["branch", "commit", "tag"];

    private readonly string _repoUri;
    private readonly string _accountName;
    private readonly string _projectName;
    private readonly string _repoName;

    private readonly IAzureDevOpsTokenProvider _tokenProvider;
    private readonly ILogger _logger;
    private readonly JsonSerializerSettings _serializerSettings;

    public AzureDevOpsClient(string accountName, string projectName, string repoName, IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryRepositoryPath)
        : base(accountName, projectName, tokenProvider, processManager, logger, temporaryRepositoryPath)
    {
        _repoUri = $"https://dev.azure.com/{accountName}/{projectName}/_git/{repoName}";
        _accountName = accountName;
        _projectName = projectName;
        _repoName = repoName;
        _tokenProvider = tokenProvider;
        _logger = logger;
        _serializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };
    }

    public AzureDevOpsClient(string repoUri, IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryRepositoryPath)
        : this(ParseRepoUri(repoUri), tokenProvider, processManager, logger, temporaryRepositoryPath)
    {
    }

    public AzureDevOpsClient((string accountName, string projectName, string name) repoInfo, IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryRepositoryPath)
        : this(repoInfo.accountName, repoInfo.projectName, repoInfo.name, tokenProvider, processManager, logger, temporaryRepositoryPath)
    {
    }

    /// <summary>
    ///     Retrieve the contents of a text file in a repo on a specific branch
    /// </summary>
    /// <param name="filePath">Path to file</param>
    /// <param name="branchOrCommit">Branch</param>
    /// <returns>Contents of file as string</returns>
    private async Task<string> GetFileContentsAsync(string filePath, string branchOrCommit)
    {
        _logger.LogInformation(
            $"Getting the contents of file '{filePath}' from repo '{_accountName}/{_projectName}/{_repoName}' in branch/commit '{branchOrCommit}'...");

        // The AzDO REST API currently does not transparently handle commits vs. branches vs. tags.
        // You really need to know whether you're talking about a commit or branch or tag
        // when you ask the question. Avoid this issue for now by first checking branch (most common)
        // then if it 404s, check commit and then tag.
        HttpRequestException lastException = null;
        foreach (var versionType in VersionTypes)
        {
            try
            {
                JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
                    HttpMethod.Get,
                    $"_apis/git/repositories/{_repoName}/items?path={filePath}&versionType={versionType}&version={branchOrCommit}&includeContent=true",
                    _logger,
                    // Don't log the failure so users don't get confused by 404 messages popping up in expected circumstances.
                    logFailure: false);
                return content["content"].ToString();
            }
            catch (HttpRequestException reqEx) when (reqEx.Message.Contains(((int)HttpStatusCode.NotFound).ToString()) || reqEx.Message.Contains(((int)HttpStatusCode.BadRequest).ToString()))
            {
                // Continue
                lastException = reqEx;
            }
        }

        throw new DependencyFileNotFoundException(filePath, _repoName, branchOrCommit, lastException);
    }

    /// <summary>
    /// Create a new branch in a repository
    /// </summary>
    /// <param name="repoUri">Repo to create a branch in</param>
    /// <param name="newBranch">New branch name</param>
    /// <param name="baseBranch">Base of new branch</param>
    public async Task CreateBranchAsync(string newBranch, string baseBranch)
    {
        var azureDevOpsRefs = new List<AzureDevOpsRef>();
        string latestSha = await GetLastCommitShaAsync(baseBranch);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/refs/heads/{newBranch}",
            _logger,
            retryCount: 0);

        AzureDevOpsRef azureDevOpsRef;

        // Azure DevOps doesn't fail with a 404 if a branch does not exist, it just returns an empty response object...
        if (content["count"].ToObject<int>() == 0)
        {
            _logger.LogInformation($"'{newBranch}' branch doesn't exist. Creating it...");

            azureDevOpsRef = new AzureDevOpsRef($"refs/heads/{newBranch}", latestSha, BaseObjectId);
            azureDevOpsRefs.Add(azureDevOpsRef);
        }
        else
        {
            _logger.LogInformation(
                $"Branch '{newBranch}' exists, making sure it is in sync with '{baseBranch}'...");

            string oldSha = await GetLastCommitShaAsync(newBranch);

            azureDevOpsRef = new AzureDevOpsRef($"refs/heads/{newBranch}", latestSha, oldSha);
            azureDevOpsRefs.Add(azureDevOpsRef);
        }

        string body = JsonConvert.SerializeObject(azureDevOpsRefs, _serializerSettings);

        await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Post,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/refs",
            _logger,
            body);
    }

    /// <summary>
    ///     Finds out whether a branch exists in the target repo.
    /// </summary>
    /// <param name="repoUri">Repository to find the branch in</param>
    /// <param name="branch">Branch to find</param>
    public async Task<bool> DoesBranchExistAsync(string branch)
    {
        branch = GitHelpers.NormalizeBranchName(branch);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/refs?filter=heads/{branch}",
            _logger,
            versionOverride: "7.0",
            logFailure: false);

        var refs = ((JArray)content["value"]).ToObject<List<AzureDevOpsRef>>();
        return refs.Any(refs => refs.Name == $"refs/heads/{branch}");
    }

    /// <summary>
    /// Deletes a branch in a repository
    /// </summary>
    /// <param name="branch">Brach to delete</param>
    /// <returns>Async Task</returns>
    public async Task DeleteBranchAsync(string branch)
    {
        string latestSha = await GetLastCommitShaAsync(branch);

        var azureDevOpsRefs = new List<AzureDevOpsRef>();
        var azureDevOpsRef = new AzureDevOpsRef($"refs/heads/{branch}", BaseObjectId, latestSha);
        azureDevOpsRefs.Add(azureDevOpsRef);

        string body = JsonConvert.SerializeObject(azureDevOpsRefs, _serializerSettings);

        await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Post,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/refs",
            _logger,
            body);
    }

    /// <summary>
    ///     Search pull requests matching the specified criteria
    /// </summary>
    /// <param name="pullRequestBranch">Source branch for PR</param>
    /// <param name="status">Current PR status</param>
    /// <param name="keyword">Keyword</param>
    /// <param name="author">Author</param>
    /// <returns>List of pull requests matching the specified criteria</returns>
    public async Task<IEnumerable<int>> SearchPullRequestsAsync(
        string pullRequestBranch,
        PrStatus status,
        string keyword = null,
        string author = null)
    {
        var query = new StringBuilder();
        var prStatus = status switch
        {
            PrStatus.Open => AzureDevOpsPrStatus.Active,
            PrStatus.Closed => AzureDevOpsPrStatus.Abandoned,
            PrStatus.Merged => AzureDevOpsPrStatus.Completed,
            _ => AzureDevOpsPrStatus.None,
        };
        query.Append($"searchCriteria.sourceRefName=refs/heads/{pullRequestBranch}&searchCriteria.status={prStatus.ToString().ToLower()}");

        if (!string.IsNullOrEmpty(keyword))
        {
            _logger.LogInformation(
                "A keyword was provided but Azure DevOps doesn't support searching for PRs based on keywords and it won't be used...");
        }

        if (!string.IsNullOrEmpty(author))
        {
            query.Append($"&searchCriteria.creatorId={author}");
        }

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/pullrequests?{query}",
            _logger);

        var values = JArray.Parse(content["value"].ToString());
        IEnumerable<int> prs = values.Select(r => r["pullRequestId"].ToObject<int>());

        return prs;
    }

    /// <summary>
    ///     Create a new pull request
    /// </summary>
    /// <param name="pullRequest">Pull request data</param>
    /// <returns>URL of new pull request</returns>
    public async Task<string> CreatePullRequestAsync(PullRequest pullRequest)
    {
        using VssConnection connection = CreateVssConnection(_accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();

        GitPullRequest createdPr = await client.CreatePullRequestAsync(
            new GitPullRequest
            {
                Title = pullRequest.Title,
                Description = TruncateDescriptionIfNeeded(pullRequest.Description),
                SourceRefName = RefsHeadsPrefix + pullRequest.HeadBranch,
                TargetRefName = RefsHeadsPrefix + pullRequest.BaseBranch,
            },
            _projectName,
            _repoName);

        return createdPr.Url;
    }

    /// <summary>
    ///     Create a new comment, or update the last comment with an updated message,
    ///     if that comment was created by Darc.
    /// </summary>
    /// <param name="pullRequestUrl">Url of pull request</param>
    /// <param name="message">Message to post</param>
    /// <remarks>
    ///     Search through the pull request comment threads to find one who's *last* comment ends
    ///     in the comment marker. If the comment is found, update it, otherwise append a comment
    ///     to the first thread that has a comment marker for any comment.
    ///     Create a new thread if no comment markers were found.
    /// </remarks>
    private async Task CreateOrUpdatePullRequestCommentAsync(string pullRequestUrl, string message)
    {
        (string accountName, string projectName, string repoName, int id) = ParsePullRequestUri(pullRequestUrl);

        using VssConnection connection = CreateVssConnection(accountName);
        using GitHttpClient client = await connection.GetClientAsync<GitHttpClient>();

        var prComment = new Comment()
        {
            CommentType = CommentType.Text,
            Content = $"{message}{CommentMarker}"
        };

        // Search threads to find ones with comment markers.
        List<GitPullRequestCommentThread> commentThreads = await client.GetThreadsAsync(repoName, id);
        foreach (GitPullRequestCommentThread commentThread in commentThreads)
        {
            // Skip non-active and non-unknown threads.  Threads that are active may appear as unknown.
            if (commentThread.Status != CommentThreadStatus.Active && commentThread.Status != CommentThreadStatus.Unknown)
            {
                continue;
            }
            List<Comment> comments = await client.GetCommentsAsync(repoName, id, commentThread.Id);
            bool threadHasCommentWithMarker = comments.Any(comment => comment.CommentType == CommentType.Text && comment.Content.EndsWith(CommentMarker));
            if (threadHasCommentWithMarker)
            {
                // Check if last comment in that thread has the marker.
                Comment lastComment = comments.Last();
                if (lastComment.CommentType == CommentType.Text && lastComment.Content.EndsWith(CommentMarker))
                {
                    // Update comment
                    await client.UpdateCommentAsync(prComment, repoName, id, commentThread.Id, lastComment.Id);
                }
                else
                {
                    // Add a new comment to the end of the thread
                    await client.CreateCommentAsync(prComment, repoName, id, commentThread.Id);
                }
                return;
            }
        }

        // No threads found, create a new one with the comment
        var newCommentThread = new GitPullRequestCommentThread()
        {
            Comments =
            [
                prComment
            ]
        };
        await client.CreateThreadAsync(newCommentThread, repoName, id);
    }

    public async Task CreateOrUpdatePullRequestMergeStatusInfoAsync(string pullRequestUrl, IReadOnlyList<MergePolicyEvaluationResult> evaluations)
    {
        await CreateOrUpdatePullRequestCommentAsync(pullRequestUrl,
            $@"## Auto-Merge Status
This pull request has not been merged because Maestro++ is waiting on the following merge policies.
{string.Join("\n", evaluations.OrderBy(r => r.MergePolicyInfo.Name).Select(DisplayPolicy))}");
    }

    private string DisplayPolicy(MergePolicyEvaluationResult result)
    {
        if (result.Status == MergePolicyEvaluationStatus.Pending)
        {
            return $"- ❓ **{result.Title}**";
        }

        if (result.Status == MergePolicyEvaluationStatus.Success)
        {
            return $"- ✔️ **{result.MergePolicyInfo.DisplayName}** Succeeded" + (result.Title == null
                ? ""
                : $" - {result.Title}");
        }

        return $"- ❌ **{result.MergePolicyInfo.DisplayName}** {result.Title}";
    }

    /// <summary>
    ///     Retrieve a set of file under a specific path at a commit
    /// </summary>
    /// <param name="commit">Commit to get files at</param>
    /// <param name="path">Path to retrieve files from</param>
    /// <returns>Set of files under <paramref name="path"/> at <paramref name="commit"/></returns>
    public async Task<List<GitFile>> GetFilesAtCommitAsync(string commit, string path)
    {
        var files = new List<GitFile>();

        _logger.LogInformation(
            $"Getting the contents of file/files in '{path}' of repo '{_repoUri}' at commit '{commit}'");

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            _projectName,
            $"_apis/git/repositories/{_repoName}/items?scopePath={path}&version={commit}&includeContent=true&versionType=commit&recursionLevel=full",
            _logger);
        List<AzureDevOpsItem> items = JsonConvert.DeserializeObject<List<AzureDevOpsItem>>(Convert.ToString(content["value"]));

        foreach (AzureDevOpsItem item in items)
        {
            if (!item.IsFolder)
            {
                if (!DependencyFileManager.DependencyFiles.Contains(item.Path))
                {
                    string fileContent = await GetFileContentsAsync(item.Path, commit);
                    var gitCommit = new GitFile(item.Path.TrimStart('/'), fileContent);
                    files.Add(gitCommit);
                }
            }
        }

        _logger.LogInformation(
            $"Getting the contents of file/files in '{path}' of repo '{_repoUri}' at commit '{commit}' succeeded!");

        return files;
    }

    /// <summary>
    ///     Get the latest commit in a repo on the specific branch 
    /// </summary>
    /// <param name="branch">Branch to retrieve the latest sha for</param>
    /// <returns>Latest sha. Null if no commits were found.</returns>
    public async Task<string> GetLastCommitShaAsync(string branch)
    {
        try
        {
            JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
                HttpMethod.Get,
                _accountName,
                _projectName,
                $"_apis/git/repositories/{_repoName}/commits?branch={branch}",
                _logger);
            var values = JArray.Parse(content["value"].ToString());

            return values[0]["commitId"].ToString();
        }
        catch (HttpRequestException exc) when (exc.Message.Contains(((int)HttpStatusCode.NotFound).ToString()))
        {
            return null;
        }
    }

    /// <summary>
    ///     Get a commit in a repo 
    /// </summary>
    /// <param name="sha">Sha of the commit</param>
    /// <returns>Return the commit matching the specified sha. Null if no commit were found.</returns>
    public async Task<Commit> GetCommitAsync(string sha)
    {
        try
        {
            JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
                HttpMethod.Get,
                _accountName,
                _projectName,
                $"_apis/git/repositories/{_repoName}/commits/{sha}",
                _logger,
                versionOverride: "6.0");
            var values = JObject.Parse(content.ToString());

            return new Commit(values["author"]["name"].ToString(), sha, values["comment"].ToString());
        }
        catch (HttpRequestException exc) when (exc.Message.Contains(((int)HttpStatusCode.NotFound).ToString()))
        {
            return null;
        }
    }

    /// <summary>
    ///     Diff two commits in a repository and return information about them.
    /// </summary>
    /// <param name="baseCommit">Base version</param>
    /// <param name="targetCommit">Target version</param>
    /// <returns>Diff information</returns>
    public async Task<GitDiff> GitDiffAsync(string baseCommit, string targetCommit)
    {
        _logger.LogInformation($"Diffing '{baseCommit}'->'{targetCommit}' in {_repoUri}");

        try
        {
            JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
                HttpMethod.Get,
                _accountName,
                _projectName,
                $"_apis/git/repositories/{_repoName}/diffs/commits?baseVersion={baseCommit}&baseVersionType=commit" +
                $"&targetVersion={targetCommit}&targetVersionType=commit",
                _logger);

            return new GitDiff()
            {
                BaseVersion = baseCommit,
                TargetVersion = targetCommit,
                Ahead = content["aheadCount"].Value<int>(),
                Behind = content["behindCount"].Value<int>(),
                Valid = true
            };
        }
        catch (HttpRequestException reqEx) when (reqEx.Message.Contains(((int)HttpStatusCode.NotFound).ToString()))
        {
            return GitDiff.UnknownDiff();
        }
    }

    /// <summary>
    /// Retrieve the list of reviews on a PR.
    /// </summary>
    /// <param name="pullRequestUrl">Uri of pull request</param>
    /// <returns>List of reviews.</returns>
    public async Task<IList<Review>> GetLatestPullRequestReviewsAsync(string pullRequestUrl)
    {
        (string accountName, string projectName, string repo, int id) = ParsePullRequestUri(pullRequestUrl);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            accountName,
            projectName,
            $"_apis/git/repositories/{repo}/pullRequests/{id}/reviewers",
            _logger);

        var values = JArray.Parse(content["value"].ToString());

        IList<Review> reviews = [];
        foreach (JToken review in values)
        {
            // Azure DevOps uses an integral "vote" value to identify review state
            // from their documentation:
            // Vote on a pull request:
            // 10 - approved 5 - approved with suggestions 0 - no vote - 5 - waiting for author - 10 - rejected

            int vote = review["vote"].Value<int>();
            var reviewState = vote switch
            {
                10 => ReviewState.Approved,
                5 => ReviewState.Commented,
                0 => ReviewState.Pending,
                -5 => ReviewState.ChangesRequested,
                -10 => ReviewState.Rejected,
                _ => throw new NotImplementedException($"Unknown review vote {vote}"),
            };
            reviews.Add(new Review(reviewState, pullRequestUrl));
        }

        return reviews;
    }

    /// <summary>
    ///     Commit or update a set of files to a repo
    /// </summary>
    /// <param name="filesToCommit">Files to comit</param>
    /// <param name="branch">Branch to push to</param>
    /// <param name="commitMessage">Commit message</param>
    public async Task CommitFilesAsync(List<GitFile> filesToCommit, string branch, string commitMessage)
        => await CommitFilesAsync(
            filesToCommit,
            _repoUri,
            branch,
            commitMessage,
            _logger,
            await _tokenProvider.GetTokenForRepositoryAsync(_repoUri),
            "DotNet-Bot",
            "dn-bot@microsoft.com");

    /// <summary>
    ///   If the release pipeline doesn't have an artifact source a new one is added.
    ///   If the pipeline has a single artifact source the artifact definition is adjusted as needed.
    ///   If the pipeline has more than one source an error is thrown.
    ///     
    ///   The artifact source added (or the adjustment) has the following properties:
    ///     - Alias: PrimaryArtifact
    ///     - Type: Single Build
    ///     - Version: Specific
    /// </summary>
    /// <param name="releaseDefinition">Release definition to be updated</param>
    /// <param name="build">Build which should be added as source of the release definition.</param>
    /// <returns>AzureDevOpsReleaseDefinition</returns>
    public async Task<AzureDevOpsReleaseDefinition> AdjustReleasePipelineArtifactSourceAsync(AzureDevOpsReleaseDefinition releaseDefinition, AzureDevOpsBuild build)
    {
        if (releaseDefinition.Artifacts == null || releaseDefinition.Artifacts.Length == 0)
        {
            releaseDefinition.Artifacts = [
                new AzureDevOpsArtifact()
                {
                    Alias = "PrimaryArtifact",
                    Type = "Build",
                    DefinitionReference = new AzureDevOpsArtifactSourceReference()
                    {
                        Definition = new AzureDevOpsIdNamePair()
                        {
                            Id = build.Definition.Id,
                            Name = build.Definition.Name
                        },
                        DefaultVersionType = new AzureDevOpsIdNamePair()
                        {
                            Id = "specificVersionType",
                            Name = "Specific version"
                        },
                        DefaultVersionSpecific = new AzureDevOpsIdNamePair()
                        {
                            Id = build.Id.ToString(),
                            Name = build.BuildNumber
                        },
                        Project = new AzureDevOpsIdNamePair()
                        {
                            Id = build.Project.Id,
                            Name = build.Project.Name
                        }
                    }
                }
            ];
        }
        else if (releaseDefinition.Artifacts.Length == 1)
        {
            var definitionReference = releaseDefinition.Artifacts[0].DefinitionReference;

            definitionReference.Definition.Id = build.Definition.Id;
            definitionReference.Definition.Name = build.Definition.Name;

            definitionReference.DefaultVersionSpecific.Id = build.Id.ToString();
            definitionReference.DefaultVersionSpecific.Name = build.BuildNumber;

            definitionReference.Project.Id = build.Project.Id;
            definitionReference.Project.Name = build.Project.Name;

            if (!releaseDefinition.Artifacts[0].Alias.Equals("PrimaryArtifact"))
            {
                _logger.LogInformation($"The artifact source Alias for the release pipeline should be 'PrimaryArtifact' got '{releaseDefinition.Artifacts[0].Alias}'. Trying to patch it.");
                releaseDefinition.Artifacts[0].Alias = "PrimaryArtifact";
            }

            if (!releaseDefinition.Artifacts[0].Type.Equals("Build"))
            {
                _logger.LogInformation($"The artifact source Type for the release pipeline should be 'Build' got '{releaseDefinition.Artifacts[0].Type}'. Trying to patch it.");
                releaseDefinition.Artifacts[0].Type = "Build";
            }

            if (!definitionReference.DefaultVersionType.Id.Equals("specificVersionType"))
            {
                _logger.LogInformation($"The artifact source Id for the release pipeline should be 'specificVersionType' got '{definitionReference.DefaultVersionType.Id}'. Trying to patch it.");
                definitionReference.DefaultVersionType.Id = "specificVersionType";
            }

            if (!definitionReference.DefaultVersionType.Name.Equals("Specific version"))
            {
                _logger.LogInformation($"The artifact source Name for the release pipeline should be 'Specific version' got '{definitionReference.DefaultVersionType.Name}'. Trying to patch it.");
                definitionReference.DefaultVersionType.Name = "Specific version";
            }
        }
        else
        {
            throw new ArgumentException($"{releaseDefinition.Artifacts.Length} artifact sources are defined in pipeline {releaseDefinition.Id}. Only one artifact source was expected.");
        }

        var _serializerSettings = new JsonSerializerSettings
        {
            ContractResolver = new CamelCasePropertyNamesContractResolver(),
            NullValueHandling = NullValueHandling.Ignore
        };

        var body = JsonConvert.SerializeObject(releaseDefinition, _serializerSettings);

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Put,
            $"_apis/release/definitions/",
            _logger,
            body,
            versionOverride: "5.0",
            baseAddressSubpath: "vsrm.");

        return content.ToObject<AzureDevOpsReleaseDefinition>();
    }

    /// <summary>
    ///     Trigger a new release using the release definition informed. No change is performed
    ///     on the release definition - it is used as is.
    /// </summary>
    /// <param name="releaseDefinition">Release definition to be updated</param>
    /// <returns>Id of the started release</returns>
    public async Task<int> StartNewReleaseAsync(AzureDevOpsReleaseDefinition releaseDefinition, int barBuildId)
    {
        var body = $"{{ \"definitionId\": {releaseDefinition.Id}, \"variables\": {{ \"BARBuildId\": {{ \"value\": \"{barBuildId}\" }} }} }}";

        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Post,
            $"_apis/release/releases/",
            _logger,
            body,
            versionOverride: "5.0",
            baseAddressSubpath: "vsrm.");

        return content.GetValue("id").ToObject<int>();
    }

    /// <summary>
    /// Checks that a repository exists
    /// </summary>
    /// <returns>True if the repository exists, false otherwise.</returns>
    public async Task<bool> RepoExistsAsync()
    {
        try
        {
            await ExecuteAzureDevOpsAPIRequestAsync(
                HttpMethod.Get,
                _accountName,
                _projectName,
                $"_apis/git/repositories/{_repoName}",
                _logger,
                logFailure: false);
            return true;
        }
        catch (Exception) { }

        return false;
    }

    /// <summary>
    /// Deletes the head branch for a pull request
    /// </summary>
    /// <param name="pullRequestUri">Pull request Uri</param>
    /// <returns>Async task</returns>
    public async Task DeletePullRequestBranchAsync(string pullRequestUri)
    {
        PullRequest pr = await GetPullRequestAsync(pullRequestUri);
        await DeleteBranchAsync(pr.HeadBranch);
    }

    public Task<string> GetFileContentsAsync(string filePath, string repoUri, string branch)
        => GetFileContentsAsync(filePath, _repoUri, branch);

    public Task CommitFilesAsync(List<GitFile> filesToCommit, string repoUri, string branch, string commitMessage)
        => CommitFilesAsync(filesToCommit, _repoUri, branch, commitMessage);

    public Task<JObject> GetBuildsAsync(string account, string project, int definitionId, string branch, int count, string status)
        => GetBuildsAsync(definitionId, branch, count, status);

    public Task<AzureDevOpsRelease> GetReleaseAsync(int releaseId)
        => GetReleaseAsync(_accountName, _projectName, releaseId);
}
