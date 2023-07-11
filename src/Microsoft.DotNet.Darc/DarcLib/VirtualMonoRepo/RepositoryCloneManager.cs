// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using LibGit2Sharp;
using Microsoft.DotNet.Darc.Models.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public record AdditionalRemote(string Mapping, string RemoteUri);

public interface IRepositoryCloneManager
{
    Task<LocalPath> PrepareClone(
        string repoUri,
        string? checkoutRef,
        bool bareClone,
        CancellationToken cancellationToken);

    Task<LocalPath> PrepareClone(
        SourceMapping mapping,
        string[] remotes,
        string? checkoutRef,
        bool bareClone,
        CancellationToken cancellationToken);
}

/// <summary>
/// When we are synchronizing other repositories into the VMR, we need to temporarily clone them.
/// This class is responsible for managing the temporary clones so that:
///   - Previously cloned repositories are re-used
///   - Re-used clones pull newest updates once per run (the first time we use them)
/// </summary>
public class RepositoryCloneManager : IRepositoryCloneManager
{
    private readonly IVmrInfo _vmrInfo;
    private readonly ILocalGitRepo _localGitRepo;
    private readonly IGitRepoClonerFactory _remoteFactory;
    private readonly IProcessManager _processManager;
    private readonly IFileSystem _fileSystem;
    private readonly ILogger<VmrPatchHandler> _logger;

    // Map of URI => dir name
    private readonly Dictionary<string, LocalPath> _clones = new();

    // Repos we have already pulled updates for during this run
    private readonly List<string> _upToDateRepos = new();

    public RepositoryCloneManager(
        IVmrInfo vmrInfo,
        ILocalGitRepo localGitRepo,
        IGitRepoClonerFactory remoteFactory,
        IProcessManager processManager,
        IFileSystem fileSystem,
        ILogger<VmrPatchHandler> logger)
    {
        _vmrInfo = vmrInfo;
        _localGitRepo = localGitRepo;
        _remoteFactory = remoteFactory;
        _processManager = processManager;
        _fileSystem = fileSystem;
        _logger = logger;
    }

    public async Task<LocalPath> PrepareClone(
        SourceMapping mapping,
        string[] remoteUris,
        string? checkoutRef,
        bool bareClone,
        CancellationToken cancellationToken)
        => await PrepareCloneInternal(remoteUris, checkoutRef, mapping.Name, bareClone, cancellationToken);

    public async Task<LocalPath> PrepareClone(
        string repoUri,
        string? checkoutRef,
        bool bareClone,
        CancellationToken cancellationToken)
        // We store clones in directories named as a hash of the repo URI
        => await PrepareCloneInternal(new[] { repoUri }, checkoutRef, StringUtils.GetXxHash64(repoUri), bareClone, cancellationToken);

    public async Task<LocalPath> PrepareCloneInternal(
        string[] remoteUris,
        string? checkoutRef,
        string cloneDir,
        bool bareClone,
        CancellationToken cancellationToken)
    {
        if (remoteUris.Length == 0)
        {
            throw new ArgumentException("No remote URIs provided to clone");
        }

        LocalPath path = null!;
        foreach (string remoteUri in remoteUris)
        {
            // Path should be returned the same for all invocations
            // We checkout a default ref
            path = await PrepareCloneInternal(remoteUri, cloneDir, bareClone, cancellationToken);
        }

        if (checkoutRef != null)
        {
            if (bareClone)
            {
                using var repository = new Repository(path);
                repository.Refs.UpdateTarget("HEAD", checkoutRef);
            }
            else
            {
                _localGitRepo.Checkout(path, checkoutRef);
            }
        }

        return path;
    }

    private async Task<LocalPath> PrepareCloneInternal(
        string remoteUri,
        string dirName,
        bool bareClone,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        if (_upToDateRepos.Contains(remoteUri))
        {
            return _clones[remoteUri];
        }

        var clonePath = _clones.TryGetValue(remoteUri, out var cachedPath)
            ? cachedPath
            : _vmrInfo.TmpPath / dirName;

        if (!_fileSystem.DirectoryExists(clonePath))
        {
            var repoCloner = _remoteFactory.GetCloner(remoteUri, _logger);
            repoCloner.Clone(remoteUri, clonePath, gitDirectory: null, bareClone);
        }
        else
        {
            _logger.LogDebug("Clone of {repo} found in {clonePath}", remoteUri, clonePath);
            _localGitRepo.AddRemoteIfMissing(clonePath, remoteUri, skipFetch: true);

            // We need to perform a full fetch and not the one provided by localGitRepo as we want all commits
            var result = await _processManager.ExecuteGit(clonePath, new[] { "fetch", remoteUri }, cancellationToken);
            result.ThrowIfFailed($"Failed to fetch changes from {remoteUri} into {clonePath}");
        }

        _upToDateRepos.Add(remoteUri);
        _clones[remoteUri] = clonePath;
        return clonePath;
    }
}
