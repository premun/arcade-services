// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Microsoft.DotNet.DarcLib.Helpers;
using System.Collections.Generic;
using System.Threading.Tasks;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public interface IVmrFileManager
{
    /// <summary>
    /// Retrieves a file's content from VMR.
    /// Either from working tree or directly from git index (when bare).
    /// </summary>
    /// <param name="path">Absolute or relative path</param>
    /// <param name="revision">Revision to get the file from</param>
    /// <param name="outputPath">Optional path to write the contents to</param>
    /// <returns>File contents</returns>
    Task<string> GetFileContent(LocalPath path, string revision = "HEAD", LocalPath? outputPath = null);

    /// <summary>
    /// Writes a file in VMR.
    /// Either into the working tree or directly into git index (when bare).
    /// </summary>
    /// <param name="path">Relative path in the VMR</param>
    /// <param name="content">File contents</param>
    Task WriteFile(UnixPath path, string content);
}

/// <summary>
/// Class responsible for reading/writing files in the VMR.
/// It can handle the VMR being checked out in bare mode and works with git index directly.
/// </summary>
public class VmrFileManager : IVmrFileManager
{
    private readonly IVmrInfo _vmrInfo;
    private readonly IProcessManager _processManager;
    private readonly IFileSystem _fileSystem;

    public VmrFileManager(IVmrInfo vmrInfo, IProcessManager processManager, IFileSystem fileSystem)
    {
        _vmrInfo = vmrInfo;
        _processManager = processManager;
        _fileSystem = fileSystem;
    }

    public async Task<string> GetFileContent(LocalPath path, string revision = VmrManagerBase.HEAD, LocalPath? outputPath = null)
    {
        var gitPath = _vmrInfo.GetGitPath(path);

        if (!_vmrInfo.BareMode && revision == VmrManagerBase.HEAD)
        {
            return await _fileSystem.ReadAllTextAsync(_vmrInfo.VmrPath / gitPath);
        }

        var args = new List<string>
        {
            "show",
            $"{revision}:{gitPath}"
        };

        if (outputPath != null)
        {
            args.Add(">");
            args.Add(outputPath);
        }

        var result = await _processManager.ExecuteGit(_vmrInfo.VmrPath, args);
        result.ThrowIfFailed($"Failed to read {gitPath} from a bare VMR at {revision}");

        return outputPath != null
            ? gitPath
            : result.StandardOutput;
    }

    public async Task WriteFile(UnixPath path, string content)
    {
        if (!_vmrInfo.BareMode)
        {
            _fileSystem.WriteToFile(_vmrInfo.VmrPath / path, content);
            return;
        }

        var gitPath = path.Path;

        // Create object in .git
        var result = await _processManager.ExecuteGit(
            _vmrInfo.VmrPath,
            "hash-object",
            "-w",
            "--path",
            gitPath,
            "<",
            content);

        result.ThrowIfFailed($"Failed to create git object for {gitPath}");

        // Register object in git index
        var objectId = result.StandardOutput.Trim();
        result = await _processManager.ExecuteGit(
            _vmrInfo.VmrPath,
            "update-index",
            "--cacheinfo",
            "100644",
            objectId,
            gitPath);

        result.ThrowIfFailed($"Failed to register git object {objectId} in git index at {gitPath}");
    }
}
