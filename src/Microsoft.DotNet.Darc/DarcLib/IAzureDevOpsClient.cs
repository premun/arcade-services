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
}
