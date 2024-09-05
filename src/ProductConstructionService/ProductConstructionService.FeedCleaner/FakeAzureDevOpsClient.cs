// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.MergePolicyEvaluation;
using Microsoft.DotNet.DarcLib;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace ProductConstructionService.FeedCleaner;

internal class FakeAzureDevOpsClientFactory : IAzureDevOpsClientFactory
{
    public IAzureDevOpsAccountClient CreateAzureDevOpsAccountClient(string accountName, string? temporaryRepositoryPath = null)
        => new FakeAzureDevOpsClient();
    public IAzureDevOpsClient CreateAzureDevOpsClient(string repoUri, string? temporaryRepositoryPath = null)
        => new FakeAzureDevOpsClient();
    public IAzureDevOpsClient CreateAzureDevOpsClient(string accountName, string projectName, string repoName, string? temporaryRepositoryPath = null)
        => new FakeAzureDevOpsClient();
    public IAzureDevOpsProjectClient CreateAzureDevOpsProjectClient(string accountName, string projectName, string? temporaryRepositoryPath = null)
        => new FakeAzureDevOpsClient();
}

// TODO (https://github.com/dotnet/arcade-services/issues/3808) delete this class and use the normal AzureDevOpsClient
internal class FakeAzureDevOpsClient : IAzureDevOpsClient, IAzureDevOpsAccountClient, IAzureDevOpsProjectClient
{
    public bool AllowRetries
    {
        get => throw new NotImplementedException();
        set => throw new NotImplementedException();
    }

    public Task<AzureDevOpsReleaseDefinition> AdjustReleasePipelineArtifactSourceAsync(AzureDevOpsReleaseDefinition releaseDefinition, AzureDevOpsBuild build)
        => throw new NotImplementedException();
    public Task CloneAsync(string repoUri, string? commit, string targetDirectory, bool checkoutSubmodules, string? gitDirectory)
        => throw new NotImplementedException();
    public Task CloneNoCheckoutAsync(string repoUri, string targetDirectory, string? gitDirectory)
        => throw new NotImplementedException();
    public Task CommitFilesAsync(List<GitFile> filesToCommit, string repoUri, string branch, string commitMessage)
        => throw new NotImplementedException();
    public Task CreateBranchAsync(string newBranch, string baseBranch)
        => throw new NotImplementedException();
    public Task CreateOrUpdatePullRequestMergeStatusInfoAsync(string pullRequestUrl, IReadOnlyList<MergePolicyEvaluationResult> evaluations)
        => throw new NotImplementedException();
    public Task<string> CreatePullRequestAsync(PullRequest pullRequest)
        => throw new NotImplementedException();
    public Task DeleteBranchAsync(string branch)
        => throw new NotImplementedException();
    public Task DeleteFeedAsync(string feedIdentifier)
        => throw new NotImplementedException();
    public Task DeleteNuGetPackageVersionFromFeedAsync(string feedIdentifier, string packageName, string version)
        => throw new NotImplementedException();
    public Task DeletePullRequestBranchAsync(string pullRequestUri)
        => throw new NotImplementedException();
    public Task<bool> DoesBranchExistAsync(string branch)
        => throw new NotImplementedException();
    public Task<JObject> ExecuteAzureDevOpsAPIRequestAsync(HttpMethod method, string accountName, string projectName, string requestPath, ILogger logger, string? body = null, string? versionOverride = null, bool logFailure = true, string? baseAddressSubpath = null, int retryCount = 15)
        => throw new NotImplementedException();
    public Task<List<AzureDevOpsBuildArtifact>> GetBuildArtifactsAsync(int buildId, int maxRetries = 15)
        => throw new NotImplementedException();
    public Task<AzureDevOpsBuild> GetBuildAsync(long buildId)
        => throw new NotImplementedException();
    public Task<JObject> GetBuildsAsync(int definitionId, string branch, int count, string status)
        => Task.FromResult(new JObject());
    public Task<Commit?> GetCommitAsync(string sha)
        => throw new NotImplementedException();
    public Task<AzureDevOpsFeed> GetFeedAndPackagesAsync(string feedIdentifier)
        => throw new NotImplementedException();
    public Task<AzureDevOpsFeed> GetFeedAsync(string feedIdentifier)
        => throw new NotImplementedException();
    public Task<List<AzureDevOpsFeed>> GetFeedsAndPackagesAsync()
        => throw new NotImplementedException();
    public Task<List<AzureDevOpsFeed>> GetFeedsAsync()
        => throw new NotImplementedException();
    public Task<string> GetFileContentsAsync(string filePath, string repoUri, string branch)
        => throw new NotImplementedException();
    public Task<List<GitFile>> GetFilesAtCommitAsync(string commit, string path)
        => throw new NotImplementedException();
    public Task<string?> GetLastCommitShaAsync(string branch)
        => throw new NotImplementedException();
    public Task<IList<Review>> GetLatestPullRequestReviewsAsync(string pullRequestUrl)
        => throw new NotImplementedException();
    public Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier, string project)
        => throw new NotImplementedException();
    public Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier)
        => throw new NotImplementedException();
    public Task<string> GetProjectIdAsync()
        => throw new NotImplementedException();
    public Task<PullRequest> GetPullRequestAsync(string pullRequestUrl)
        => throw new NotImplementedException();
    public Task<IList<Check>> GetPullRequestChecksAsync(string pullRequestUrl)
        => throw new NotImplementedException();
    public Task<IList<Commit>> GetPullRequestCommitsAsync(string pullRequestUrl)
        => throw new NotImplementedException();
    public Task<PrStatus> GetPullRequestStatusAsync(string pullRequestUrl)
        => throw new NotImplementedException();
    public Task<AzureDevOpsRelease> GetReleaseAsync(string accountName, string projectName, int releaseId)
        => throw new NotImplementedException();
    public Task<GitDiff> GitDiffAsync(string baseVersion, string targetVersion)
        => throw new NotImplementedException();
    public Task MergeDependencyPullRequestAsync(string pullRequestUrl, MergePullRequestParameters parameters, string mergeCommitMessage)
        => throw new NotImplementedException();
    public Task<bool> RepoExistsAsync()
        => throw new NotImplementedException();
    public Task<IEnumerable<int>> SearchPullRequestsAsync(string pullRequestBranch, PrStatus status, string? keyword = null, string? author = null)
        => throw new NotImplementedException();
    public Task<int> StartNewBuildAsync(
            int azdoDefinitionId,
            string sourceBranch,
            string sourceVersion,
            Dictionary<string, string>? queueTimeVariables = null,
            Dictionary<string, string>? templateParameters = null,
            Dictionary<string, string>? pipelineResources = null)
        => throw new NotImplementedException();
    public Task UpdatePullRequestAsync(string pullRequestUri, PullRequest pullRequest)
        => throw new NotImplementedException();
}
