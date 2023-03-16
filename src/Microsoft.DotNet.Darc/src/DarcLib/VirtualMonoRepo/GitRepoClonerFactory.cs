// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;
using System;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public interface IGitRepoClonerFactory
{
    IGitRepoCloner GetCloner(string repoUrl, ILogger logger);
}

public class GitRepoClonerFactory : IGitRepoClonerFactory
{
    private readonly VmrRemoteConfiguration _vmrRemoteConfig;
    private readonly IProcessManager _processManager;

    public GitRepoClonerFactory(VmrRemoteConfiguration vmrRemoteConfig, IProcessManager processManager)
    {
        _vmrRemoteConfig = vmrRemoteConfig;
        _processManager = processManager;
    }

    public IGitRepoCloner GetCloner(string repoUri, ILogger logger) => GitRepoTypeParser.ParseFromUri(repoUri) switch
    {
        GitRepoType.GitHub => new GitRepoCloner(_vmrRemoteConfig.GitHubToken, _processManager.GitExecutable, logger),
        GitRepoType.AzureDevOps => new GitRepoCloner(_vmrRemoteConfig.AzureDevOpsToken, _processManager.GitExecutable, logger),
        GitRepoType.Local => new GitRepoCloner(string.Empty, _processManager.GitExecutable, logger),
        _ => throw new NotImplementedException($"Unsupported repository remote {repoUri}"),
    };
}


