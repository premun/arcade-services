// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.Extensions.Logging;

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
    private readonly IVmrPatchHandler _patchHandler;
    private readonly IProcessManager _processManager;
    private readonly ILogger<IVmrBackflowManager> _logger;

    public VmrBackflowManager(
        IVmrInfo vmrInfo,
        VmrRemoteConfiguration remoteConfiguration,
        IVmrPatchHandler patchHandler,
        IProcessManager processManager,
        ILogger<IVmrBackflowManager> logger)
    {
        _vmrInfo = vmrInfo;
        _remoteConfiguration = remoteConfiguration;
        _patchHandler = patchHandler;
        _processManager = processManager;
        _logger = logger;
    }

    public async Task Backflow(CancellationToken cancellationToken)
    {
        var githubClient = new GitHubClient(
            _processManager.GitExecutable,
            _remoteConfiguration.GitHubToken,
            _logger,
            _vmrInfo.TmpPath,
            // Caching not in use for Darc local client
            null);
            
        var user = await githubClient.Client.User.Current();
        // TODO: Verify scopes and tell user to set a token with the right ones using `darc authenticate`
        Console.WriteLine($"Using authenticated GitHub user {user.Login}");

        var result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, "symbolic-ref", "-q", "HEAD");
        result.ThrowIfFailed($"Failed to determine branch for {_vmrInfo.VmrPath}");

        var sourceBranch = result.StandardOutput.Trim();
        var prefix = "refs/heads/";
        if (sourceBranch.StartsWith(prefix))
        {
            sourceBranch = sourceBranch.Substring(prefix.Length);
        }

        sourceBranch = PromptUser("Source branch with the changes", sourceBranch);
        var targetBranch = PromptUser("Target branch for the changes", "main");

        if (sourceBranch == targetBranch)
        {
            throw new InvalidOperationException($"Source and target branches must be different ({sourceBranch}/{targetBranch})");
        }

        // TODO: Better patch name
        var patchName = _vmrInfo.TmpPath / "vmr.patch";

        // Find common ancestor for branches
        result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, new[] { "merge-base", sourceBranch, targetBranch }, cancellationToken);
        result.ThrowIfFailed($"Failed to find common ancestor for branches {targetBranch} and {sourceBranch}");
        var mainAncestor = result.StandardOutput.Trim();

        var args = new List<string>
        {
            "diff",
            "--patch",
            "--binary", // Include binary contents as base64
            $"--output={patchName}", // Store the diff in a .patch file
            $"{mainAncestor}..{sourceBranch}",
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

            return path.Substring(4, path.IndexOf('/', 4));
        });

        var nonSrcFiles = filesByRepo.FirstOrDefault(group => group.Key == nonSrcKey);
        if (nonSrcFiles != null)
        {
            foreach (var nonSrcFile in nonSrcFiles)
            {
                _logger.LogWarning("File {file} is outside of src/ and will be ignored", nonSrcFile);
            }
        }

        
    }

    private static string PromptUser(string prompt, string? defaultValue = null, bool readCharOnly = false)
    {
        Console.Write($"{prompt} ");
        var originalColor = Console.ForegroundColor;
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write($"[{defaultValue}]");
        Console.ForegroundColor = originalColor;
        Console.Write(": ");
        string? input = readCharOnly ? Console.ReadKey().KeyChar.ToString() : Console.ReadLine();

        if (string.IsNullOrWhiteSpace(input))
        {
            if (defaultValue == null)
            {
                return PromptUser(prompt, defaultValue, readCharOnly);
            }

            input = defaultValue;
        }

        return input.Trim() ?? throw new Exception("Input required");
    }

    private static bool PromptUserYesNo(string prompt, char defaultValue = 'y')
    {
        var key = PromptUser(prompt + (defaultValue == 'y' ? " [Y/n]" : " [y/N]"), defaultValue.ToString(), true)[0];

        return key == 'y' || key == 'Y';
    }
}
