﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Common.AzureDevOpsTokens;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;

#nullable enable
namespace Microsoft.DotNet.DarcLib;

public interface IAzureDevOpsClientFactory
{
    IAzureDevOpsClient CreateAzureDevOpsClient(string repoUri, string? temporaryRepositoryPath = null);

    IAzureDevOpsClient CreateAzureDevOpsClient(string accountName, string projectName, string repoName, string? temporaryRepositoryPath = null);
}

public class AzureDevOpsClientFactory(IAzureDevOpsTokenProvider tokenProvider, IProcessManager processManager, ILogger logger, string? temporaryRepositoryPath = null) : IAzureDevOpsClientFactory
{
    private readonly string? _temporaryRepositoryPath = temporaryRepositoryPath;

    public IAzureDevOpsClient CreateAzureDevOpsClient(string repoUri, string? temporaryRepositoryPath = null)
    {
        (string accountName, string projectName, string repoName) = AzureDevOpsClient.ParseRepoUri(repoUri);
        return CreateAzureDevOpsClient(accountName, projectName, repoName, temporaryRepositoryPath);
    }

    public IAzureDevOpsClient CreateAzureDevOpsClient(string accountName, string projectName, string repoName, string? temporaryRepositoryPath = null)
    {
        return new AzureDevOpsClient(accountName, projectName, repoName, tokenProvider, processManager, logger, temporaryRepositoryPath ?? _temporaryRepositoryPath);
    }
}
