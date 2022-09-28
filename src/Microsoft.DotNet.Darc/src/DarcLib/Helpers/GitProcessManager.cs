// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using System.Runtime.InteropServices;

#nullable enable
namespace Microsoft.DotNet.DarcLib.Helpers;

public class GitProcessManager : ProcessManager, IGitProcessManager
{
    public string GitExecutable { get; }

    public GitProcessManager(ILogger<IProcessManager> logger, string gitExecutable)
        : base(logger)
    {
        GitExecutable = gitExecutable;
    }

    public Task<ProcessExecutionResult> ExecuteGit(string repoPath, string[] arguments, CancellationToken cancellationToken)
        => Execute(GitExecutable, (new[] { "-C", repoPath }).Concat(arguments), cancellationToken: cancellationToken);

    /// <summary>
    /// Traverses the directory structure from given path up until it finds a .git folder.
    /// </summary>
    /// <param name="path">tarting directory</param>
    /// <returns>A root of a git repository (throws when no .git found)</returns>
    public async Task<string> FindGitRoot(string? path = null, CancellationToken cancellationToken = default)
    {
        path ??= Environment.CurrentDirectory;

        var result = await ExecuteGit(path, new[] { "rev-parse", "--show-toplevel" }, cancellationToken);

        if (!result.Succeeded)
        {
            throw new Exception($"Failed to find parent git repository for {path}");
        }

        return result.StandardOutput.Trim();
    }

    public async Task<string> GetEditorPath(string? repoPath = null, CancellationToken cancellationToken = default)
    {
        var result = await ExecuteGit(
            repoPath ?? Environment.CurrentDirectory,
            new[] { "config", "--get core.editor" },
            cancellationToken);

        string? editor = null;
        if (result.Succeeded)
        {
            editor = result.StandardOutput.Trim();
        }

        // If there is nothing set in core.editor we try to default it to notepad if running in Windows,
        // if not default it to vim
        if (string.IsNullOrEmpty(editor))
        {
            ProcessExecutionResult whereResult = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
                ? await Execute("where", new[] { "notepad" }, cancellationToken: cancellationToken)
                : await Execute("which", new[] { "vim" }, cancellationToken: cancellationToken);

            whereResult.ThrowIfFailed("Failed to locate notepad/vim");
            editor = whereResult.StandardOutput.Trim();
        }

        // Split this by newline in case where are multiple paths;
        int newlineIndex = editor.IndexOf(Environment.NewLine);
        if (newlineIndex != -1)
        {
            editor = editor[..newlineIndex];
        }

        return editor;
    }
}
