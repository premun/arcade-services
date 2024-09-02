// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Common.AzureDevOpsTokens;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;

#nullable enable
namespace Microsoft.DotNet.DarcLib;

public interface IAzureDevOpsClientFactory
{
    IAzureDevOpsClient GetAzureDevOpsClient(string repoUri, string? temporaryRepositoryPath = null);
}

public class AzureDevOpsClientFactory(IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger) : IAzureDevOpsClientFactory
{
    public AzureDevOpsClient GetAzureDevOpsClient(string repoUri, string? temporaryRepositoryPath = null)
    {
        return new AzureDevOpsClient(repoUri, tokenProvider, processManager, logger, temporaryRepositoryPath);
    }
}
