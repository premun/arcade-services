// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LibGit2Sharp;
using Microsoft.DotNet.Darc.Models.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;
using Octokit;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public interface IVmrBackflowManager
{
    Task Backflow(CancellationToken cancellationToken);
}

public class VmrBackflowManager : IVmrBackflowManager
{
    private readonly IVmrInfo _vmrInfo;
    private readonly VmrRemoteConfiguration _remoteConfiguration;
    private readonly ISourceManifest _sourceManifest;
    private readonly IVmrDependencyTracker _dependencyTracker;
    private readonly IVmrPatchHandler _patchHandler;
    private readonly IGitRepoClonerFactory _gitRepoClonerFactory;
    private readonly ILocalGitRepo _localGitRepo;
    private readonly IProcessManager _processManager;
    private readonly ILogger<IVmrBackflowManager> _logger;

    public VmrBackflowManager(
        IVmrInfo vmrInfo,
        VmrRemoteConfiguration remoteConfiguration,
        ISourceManifest sourceManifest,
        IVmrDependencyTracker dependencyTracker,
        IVmrPatchHandler patchHandler,
        IGitRepoClonerFactory gitRepoClonerFactory,
        ILocalGitRepo localGitRepo,
        IProcessManager processManager,
        ILogger<IVmrBackflowManager> logger)
    {
        _vmrInfo = vmrInfo;
        _remoteConfiguration = remoteConfiguration;
        _sourceManifest = sourceManifest;
        _dependencyTracker = dependencyTracker;
        _patchHandler = patchHandler;
        _gitRepoClonerFactory = gitRepoClonerFactory;
        _localGitRepo = localGitRepo;
        _processManager = processManager;
        _logger = logger;
    }

    public async Task Backflow(CancellationToken cancellationToken)
    {
        await _dependencyTracker.InitializeSourceMappings();

        var githubClient = new GitHubClient(
            _processManager.GitExecutable,
            _remoteConfiguration.GitHubToken,
            _logger,
            _vmrInfo.TmpPath,
            // Caching not in use for Darc local client
            null);

        User user = await githubClient.Client.User.Current();
        // TODO: Verify scopes and tell user to set a token with the right ones using `darc authenticate`
        Console.WriteLine($"Using authenticated GitHub user {user.Login}");

        var result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, new[] { "symbolic-ref", "-q", "HEAD" }, cancellationToken);
        result.ThrowIfFailed($"Failed to determine branch for {_vmrInfo.VmrPath}");

        var sourceBranch = result.StandardOutput.Trim();
        var prefix = "refs/heads/";
        if (sourceBranch.StartsWith(prefix))
        {
            sourceBranch = sourceBranch.Substring(prefix.Length);
        }

        sourceBranch = ConsoleHelper.PromptUser("Source branch with the changes", sourceBranch);
        var targetBranch = ConsoleHelper.PromptUser("Target branch for the changes", "main");

        if (sourceBranch == targetBranch)
        {
            throw new InvalidOperationException($"Source and target branches must be different ({sourceBranch}/{targetBranch})");
        }

        // TODO: Better patch name
        var patchName = _vmrInfo.TmpPath / "vmr.patch";

        // Find common ancestor for branches
        result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, new[] { "merge-base", sourceBranch, targetBranch }, cancellationToken);
        result.ThrowIfFailed($"Failed to find common ancestor for branches {targetBranch} and {sourceBranch}");
        var fromSha = result.StandardOutput.Trim();

        // Resolve SHA of the target commit
        result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, new[] { "show-ref", sourceBranch }, cancellationToken);
        result.ThrowIfFailed($"Failed to find common ancestor for branches {targetBranch} and {sourceBranch}");
        var toSha = result.StandardOutput.Split(new[] { '\r', '\n', ' ' }, StringSplitOptions.RemoveEmptyEntries).First();

        var args = new List<string>
        {
            "diff",
            "--patch",
            "--binary", // Include binary contents as base64
            $"--output={patchName}", // Store the diff in a .patch file
            $"{fromSha}..{toSha}",
        };

        result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, args, cancellationToken);
        result.ThrowIfFailed("Failed to read the VMR changes");

        var changedFiles = await _patchHandler.GetPatchedFiles(patchName, cancellationToken);

        var nonSrcKey = "/";
        var filesByRepo = changedFiles.ToLookup(file =>
        {
            var path = file.ToString();
            if (!path.StartsWith("src/"))
            {
                // Files outside of src/ need to be considered separately
                return nonSrcKey;
            }

            return path[4..path.IndexOf('/', 4)];
        });

        var nonSrcFiles = filesByRepo.FirstOrDefault(group => group.Key == nonSrcKey);
        if (nonSrcFiles != null)
        {
            foreach (var nonSrcFile in nonSrcFiles)
            {
                _logger.LogWarning("File {file} is outside of src/ and will be ignored", nonSrcFile);
            }

            // Flush
            Thread.Sleep(100);
        }

        var byRepoChanges = filesByRepo.Where(group => group.Key != nonSrcKey);

        _logger.LogInformation("There are {changeCount} changes in {repoCount} repos",
            byRepoChanges.Sum(group => group.Count()),
            byRepoChanges.Count());

        string baseUri = $"https://github.com/{user.Login}/";
        string? prTitle = null;

        foreach (var group in byRepoChanges)
        {
            Console.WriteLine();

            var mapping = _dependencyTracker.Mappings.First(m => m.Name == group.Key);
            var count = group.Count();

            if (!ConsoleHelper.PromptUserYesNo($"Flow back changes for {mapping.Name} ({count} file{(count == 1 ? string.Empty : "s")})"))
            {
                continue;
            }

            string targetRepoUri = ConsoleHelper.PromptUser("  Where do you want the PR branch created", $"{baseUri}{mapping.Name}");
            string prBranch = ConsoleHelper.PromptUser("  PR branch name", $"{sourceBranch}");
            prTitle = ConsoleHelper.PromptUser($"  PR title", prTitle);
            Console.WriteLine("  Creating PR...");

            await BackflowRepository(mapping, fromSha, toSha, targetRepoUri, prBranch, prTitle, user, cancellationToken);
        }
    }

    private async Task BackflowRepository(
        SourceMapping mapping,
        string fromSha,
        string toSha,
        string targetUri,
        string branchName,
        string prTitle,
        User committer,
        CancellationToken cancellationToken)
    {
        var repo = _sourceManifest.Repositories.First(r => r.Path == mapping.Name)
            ?? throw new Exception($"Repo {mapping.Name} has not been initialized in the VMR yet");

        var repoPatch = _vmrInfo.TmpPath / $"{mapping.Name}-{Commit.GetShortSha(repo.CommitSha)}.patch";

        var args = new List<string>
        {
            "diff",
            "--patch",
            "--binary", // Include binary contents as base64
            "--relative", // Treat paths as relative to cwd
            $"--output={repoPatch}", // Store the diff in a .patch file
            $"{fromSha}..{toSha}",
        };

        var result = await _processManager.Execute(
            _processManager.GitExecutable,
            args,
            workingDir: _vmrInfo.GetRepoSourcesPath(mapping),
            cancellationToken: cancellationToken);

        result.ThrowIfFailed($"Failed to create a patch for {mapping.Name}");

        var cloner = _gitRepoClonerFactory.GetCloner(repo.RemoteUri, _logger);
        var clonePath = _vmrInfo.TmpPath / (mapping.Name + "-sparse");
        if (Directory.Exists(clonePath))
        {
            Directory.Delete(clonePath, true);
        }

        var changedFile = await _patchHandler.GetPatchedFiles(repoPatch, cancellationToken);
        cloner.SparseClone(repo.RemoteUri, repo.CommitSha, clonePath, changedFile.Select(f => f.ToString()).ToArray());

        targetUri = targetUri.Replace("https://", $"https://{committer.Login}:{_remoteConfiguration.GitHubToken}@");
        var remoteName = _localGitRepo.AddRemoteIfMissing(clonePath, targetUri, skipFetch: true);

        await _patchHandler.ApplyPatch(new VmrIngestionPatch(repoPatch, (string?) null), clonePath, cancellationToken);

        using var repository = new LibGit2Sharp.Repository(clonePath);
        LibGit2Sharp.Branch branch = repository.Branches.Add(branchName, "HEAD", allowOverwrite: true);
        Commands.Checkout(repository, branch);
        var author = new LibGit2Sharp.Signature(committer.Name, committer.Email, DateTimeOffset.Now);
        var commit = repository.Commit(prTitle, author, author);

        result = await _processManager.ExecuteGit(clonePath, new[] { "push", remoteName, branchName }, cancellationToken);
        result.ThrowIfFailed($"Failed to push to {targetUri}");

        Console.WriteLine($"  Pushed {branchName} to {targetUri}");
    }
}
