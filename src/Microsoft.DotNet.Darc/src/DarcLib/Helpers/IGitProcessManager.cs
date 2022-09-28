// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;

#nullable enable
namespace Microsoft.DotNet.DarcLib.Helpers;

public interface IGitProcessManager : IProcessManager
{
    string GitExecutable { get; }
    
    Task<ProcessExecutionResult> ExecuteGit(string repoPath, string[] arguments, CancellationToken cancellationToken);

    Task<ProcessExecutionResult> ExecuteGit(string repoPath, params string[] arguments)
        => ExecuteGit(repoPath, arguments.ToArray(), default);
    
    Task<ProcessExecutionResult> ExecuteGit(
        string repoPath,
        IEnumerable<string> arguments,
        CancellationToken cancellationToken = default)
        => ExecuteGit(repoPath, arguments.ToArray(), cancellationToken);

    Task<string> FindGitRoot(string? repoPath = null, CancellationToken cancellationToken = default);

    Task<string> GetEditorPath(string? repoPath = null, CancellationToken cancellationToken = default);
}
