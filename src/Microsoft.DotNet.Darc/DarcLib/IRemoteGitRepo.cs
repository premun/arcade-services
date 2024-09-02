// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.MergePolicyEvaluation;
using System.Collections.Generic;
using System.Threading.Tasks;

#nullable enable
namespace Microsoft.DotNet.DarcLib;

public interface IRemoteGitRepo : IGitRepoCloner, IGitRepo
{
    /// <summary>
    /// Specifies whether functions with a retry field should employ retries
    /// Should default to true
    /// </summary>
    bool AllowRetries { get; set; }

    /// <summary>
    /// Checks that a repository exists
    /// </summary>
    /// <returns>True if the repository exists, false otherwise.</returns>
    Task<bool> RepoExistsAsync();

    /// <summary>
    /// Create a new branch in a repository
    /// </summary>
    /// <param name="newBranch">New branch name</param>
    /// <param name="baseBranch">Base of new branch</param>
    Task CreateBranchAsync(string newBranch, string baseBranch);

    /// <summary>
    /// Delete a branch from a repository
    /// </summary>
    /// <param name="branch">The branch to delete</param>
    Task DeleteBranchAsync(string branch);

    /// <summary>
    ///     Search pull requests matching the specified criteria
    /// </summary>
    /// <param name="pullRequestBranch">Source branch for PR</param>
    /// <param name="status">Current PR status</param>
    /// <param name="keyword">Keyword</param>
    /// <param name="author">Author</param>
    /// <returns>List of pull requests matching the specified criteria</returns>
    Task<IEnumerable<int>> SearchPullRequestsAsync(
        string pullRequestBranch,
        PrStatus status,
        string? keyword = null,
        string? author = null);

    /// <summary>
    /// Get the status of a pull request
    /// </summary>
    /// <param name="pullRequestUrl">URI of pull request</param>
    /// <returns>Pull request status</returns>
    Task<PrStatus> GetPullRequestStatusAsync(string pullRequestUrl);

    /// <summary>
    ///     Retrieve information on a specific pull request
    /// </summary>
    /// <param name="pullRequestUrl">Uri of the pull request</param>
    /// <returns>Information on the pull request.</returns>
    Task<PullRequest> GetPullRequestAsync(string pullRequestUrl);

    /// <summary>
    ///     Retrieve information on commits of a specific pull request
    /// </summary>
    /// <param name="pullRequestUrl">Uri of the pull request</param>
    /// <returns>Information on the pull request.</returns>
    Task<IList<Commit>> GetPullRequestCommitsAsync(string pullRequestUrl);

    /// <summary>
    ///     Create a new pull request for a repository
    /// </summary>
    /// <param name="repoUri">Repo to create the pull request for.</param>
    /// <param name="pullRequest">Pull request data</param>
    Task<string> CreatePullRequestAsync(PullRequest pullRequest);

    /// <summary>
    ///     Update a pull request with new information
    /// </summary>
    /// <param name="pullRequestUri">Uri of pull request to update</param>
    /// <param name="pullRequest">Pull request info to update</param>
    Task UpdatePullRequestAsync(string pullRequestUri, PullRequest pullRequest);


    /// <summary>
    ///     Merges a Dependency update pull request
    /// </summary>
    /// <param name="pullRequestUrl">Uri of pull request to merge</param>
    /// <param name="parameters">Settings for merge</param>
    /// <param name="mergeCommitMessage">Commit message used to merge the pull request</param>
    Task MergeDependencyPullRequestAsync(string pullRequestUrl, MergePullRequestParameters parameters, string mergeCommitMessage);

    /// <summary>
    ///     Create new check(s), update them with a new status,
    ///     or remove each merge policy check that isn't in evaluations
    /// </summary>
    /// <param name="pullRequestUrl">Url of pull request</param>
    /// <param name="evaluations">List of merge policies</param>
    Task CreateOrUpdatePullRequestMergeStatusInfoAsync(string pullRequestUrl, IReadOnlyList<MergePolicyEvaluationResult> evaluations);

    /// <summary>
    ///     Get the latest commit in a repo on the specific branch 
    /// </summary>
    /// <param name="branch">Branch to retrieve the latest sha for</param>
    /// <returns>Latest sha.  Null if no commits were found.</returns>
    Task<string?> GetLastCommitShaAsync(string branch);

    /// <summary>
    ///     Get a commit in a repo 
    /// </summary>
    /// <param name="sha">Sha of the commit</param>
    /// <returns>Return the commit matching the specified sha. Null if no commit were found.</returns>
    Task<Commit?> GetCommitAsync(string sha);

    /// <summary>
    /// Gets a list of file under a given path in a given revision.
    /// </summary>
    Task<List<GitFile>> GetFilesAtCommitAsync(string commit, string path);

    /// <summary>
    /// Retrieve the list of status checks on a PR.
    /// </summary>
    /// <param name="pullRequestUrl">Uri of pull request</param>
    /// <returns>List of status checks.</returns>
    Task<IList<Check>> GetPullRequestChecksAsync(string pullRequestUrl);

    /// <summary>
    /// Retrieve the list of reviews on a PR.
    /// </summary>
    /// <param name="pullRequestUrl">Uri of pull request</param>
    /// <returns>List of pull request reviews.</returns>
    Task<IList<Review>> GetLatestPullRequestReviewsAsync(string pullRequestUrl);

    /// <summary>
    ///     Diff two commits in a repository and return information about them.
    /// </summary>
    /// <param name="baseVersion">Base version</param>
    /// <param name="targetVersion">Target version</param>
    /// <returns>Diff information</returns>
    Task<GitDiff> GitDiffAsync(string baseVersion, string targetVersion);

    /// <summary>
    ///     Delete a pull request's branch if it still exists
    /// </summary>
    /// <param name="pullRequestUri"></param>
    /// <returns>Async task</returns>
    Task DeletePullRequestBranchAsync(string pullRequestUri);

    /// <summary>
    ///     Finds out whether a branch exists in the target repo.
    /// </summary>
    /// <param name="branch">Branch to find</param>
    Task<bool> DoesBranchExistAsync(string branch);
}

#nullable disable
public class PullRequest
{
    public string Title { get; set; }
    public string Description { get; set; }
    public string BaseBranch { get; set; }
    public string HeadBranch { get; set; }
}
