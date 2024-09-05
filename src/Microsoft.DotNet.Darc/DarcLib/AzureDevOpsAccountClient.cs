// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Maestro.Common.AzureDevOpsTokens;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace Microsoft.DotNet.DarcLib;

public interface IAzureDevOpsAccountClient
{
    Task<List<AzureDevOpsFeed>> GetFeedsAsync();
    Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier, string project);
}

public class AzureDevOpsAccountClient : AzureDevOpsBaseClient, IAzureDevOpsAccountClient
{
    private readonly string _accountName;
    private readonly ILogger _logger;

    public AzureDevOpsAccountClient(string accountName, IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string temporaryPath)
        : base(tokenProvider, processManager, logger, temporaryPath)
    {
        _accountName = accountName;
        _logger = logger;
    }

    /// <summary>
    ///   Gets all Artifact feeds in an Azure DevOps account.
    /// </summary>
    /// <returns>List of Azure DevOps feeds in the account</returns>
    public async Task<List<AzureDevOpsFeed>> GetFeedsAsync()
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            null,
            $"_apis/packaging/feeds",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "feeds.");

        var list = ((JArray)content["value"]).ToObject<List<AzureDevOpsFeed>>();
        list.ForEach(f => f.Account = _accountName);
        return list;
    }

    /// <summary>
    /// Gets all packages in a given Azure DevOps feed
    /// </summary>
    /// <param name="project">Project that the feed was created in</param>
    /// <param name="feedIdentifier">Name or id of the feed</param>
    /// <returns>List of packages in the feed</returns>
    public async Task<List<AzureDevOpsPackage>> GetPackagesForFeedAsync(string feedIdentifier, string project)
    {
        JObject content = await ExecuteAzureDevOpsAPIRequestAsync(
            HttpMethod.Get,
            _accountName,
            project,
            $"_apis/packaging/feeds/{feedIdentifier}/packages?includeAllVersions=true&includeDeleted=true",
            _logger,
            versionOverride: "5.1-preview.1",
            baseAddressSubpath: "feeds.");

        return ((JArray)content["value"]).ToObject<List<AzureDevOpsPackage>>();
    }
}
