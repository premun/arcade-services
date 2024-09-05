// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace Microsoft.DotNet.DarcLib;

public interface IAzureDevOpsClient : IRemoteGitRepo
{
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
    Task<AzureDevOpsReleaseDefinition> AdjustReleasePipelineArtifactSourceAsync(AzureDevOpsReleaseDefinition releaseDefinition, AzureDevOpsBuild build);

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
    Task<JObject> ExecuteAzureDevOpsAPIRequestAsync(
        HttpMethod method,
        string accountName,
        string projectName,
        string requestPath,
        ILogger logger,
        string body = null,
        string versionOverride = null,
        bool logFailure = true,
        string baseAddressSubpath = null,
        int retryCount = 15);

    /// <summary>
    ///   Deletes an Azure Artifacts feed and all of its packages
    /// </summary>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <returns>Async task</returns>
    Task DeleteFeedAsync(string feedIdentifier);

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
    ///   Fetches a list of last run AzDO builds for a given build definition.
    /// </summary>
    /// <param name="account">Azure DevOps account name</param>
    /// <param name="project">Project name</param>
    /// <param name="definitionId">Id of the pipeline (build definition)</param>
    /// <param name="branch">Filter by branch</param>
    /// <param name="count">Number of builds to retrieve</param>
    /// <param name="status">Filter by status</param>
    Task<JObject> GetBuildsAsync(string account, string project, int definitionId, string branch, int count, string status);

    /// <summary>
    ///   Fetches artifacts belonging to a given AzDO build.
    /// </summary>
    /// <param name="buildId">Id of the build to be retrieved</param>
    /// <returns>List of build artifacts</returns>
    Task<List<AzureDevOpsBuildArtifact>> GetBuildArtifactsAsync(int buildId, int maxRetries = 15);

    /// <summary>
    ///   Gets a specified Artifact feed with their pacckages in an Azure DevOps account.
    /// </summary>
    /// <param name="feedIdentifier">ID or name of the feed.</param>
    /// <returns>List of Azure DevOps feeds in the account.</returns>
    Task<AzureDevOpsFeed> GetFeedAndPackagesAsync(string feedIdentifier);

    /// <summary>
    ///   Gets a specified Artifact feed in an Azure DevOps account.
    /// </summary>
    /// <param name="feedIdentifier">ID or name of the feed</param>
    /// <returns>List of Azure DevOps feeds in the account</returns>
    Task<AzureDevOpsFeed> GetFeedAsync(string feedIdentifier);

    /// <summary>
    ///   Gets all Artifact feeds along with their packages in an Azure DevOps account.
    /// </summary>
    /// <returns>List of Azure DevOps feeds in the account.</returns>
    Task<List<AzureDevOpsFeed>> GetFeedsAndPackagesAsync();

    /// <summary>
    ///   Gets all Artifact feeds in an Azure DevOps account.
    /// </summary>
    /// <returns>List of Azure DevOps feeds in the account</returns>
    Task<List<AzureDevOpsFeed>> GetFeedsAsync();

    /// <summary>
    ///   Gets all Artifact feeds along with their packages in an Azure DevOps account.
    /// </summary>
    /// <returns>List of Azure DevOps feeds in the account.</returns>
    Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier);

    /// <summary>
    ///   Returns the project ID for a combination of Azure DevOps account and project name
    /// </summary>
    /// <returns>Project Id</returns>
    Task<string> GetProjectIdAsync();

    /// <summary>
    ///   Return the description of the release with ID informed.
    /// </summary>
    /// <param name="releaseId">ID of the release that should be looked up for</param>
    /// <returns>AzureDevOpsRelease</returns>
    Task<AzureDevOpsRelease> GetReleaseAsync(int releaseId);

    /// <summary>
    ///   Fetches an specific AzDO release definition based on its ID.
    /// </summary>
    /// <param name="releaseDefinitionId">Id of the release definition to be retrieved</param>
    /// <returns>AzureDevOpsReleaseDefinition</returns>
    Task<AzureDevOpsReleaseDefinition> GetReleaseDefinitionAsync(long releaseDefinitionId);

    /// <summary>
    ///   Queue a new build on the specified build definition with the given queue time variables.
    /// </summary>
    /// <param name="buildDefinitionId">ID of the build definition where a build should be queued.</param>
    /// <param name="queueTimeVariables">Queue time variables as a Dictionary of (variable name, value).</param>
    /// <param name="templateParameters">Template parameters as a Dictionary of (variable name, value).</param>
    /// <param name="pipelineResources">Pipeline resources as a Dictionary of (pipeline resource name, build number).</param>
    Task<int> StartNewBuildAsync(
        int buildDefinitionId,
        string sourceBranch,
        string sourceVersion,
        Dictionary<string, string> queueTimeVariables = null,
        Dictionary<string, string> templateParameters = null,
        Dictionary<string, string> pipelineResources = null);

    /// <summary>
    ///   Trigger a new release using the release definition informed. No change is performed
    ///   on the release definition - it is used as is.
    /// </summary>
    /// <param name="releaseDefinition">Release definition to be updated</param>
    /// <returns>Id of the started release</returns>
    Task<int> StartNewReleaseAsync(AzureDevOpsReleaseDefinition releaseDefinition, int barBuildId);
}
