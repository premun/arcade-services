// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Models.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.Helpers;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public class VmrInfo : IVmrInfo
{
    public const string SourcesDir = "src";
    public const string SourceMappingsFileName = "source-mappings.json";
    public const string GitInfoSourcesDir = "prereqs/git-info";
    public const string SourceManifestFileName = "source-manifest.json";

    // These git attributes can override cloaking of files when set it individual repositories
    public const string KeepAttribute = "vmr-preserve";
    public const string IgnoreAttribute = "vmr-ignore";

    public const string ReadmeFileName = "README.md";
    public const string ThirdPartyNoticesFileName = "THIRD-PARTY-NOTICES.txt";

    private readonly IProcessManager _processManager;

    public static UnixPath RelativeSourcesDir { get; } = new("src");

    public LocalPath VmrPath { get; }

    public LocalPath TmpPath { get; }

    public string? PatchesPath { get; set; }

    public string? SourceMappingsPath { get; set; }

    public IReadOnlyCollection<(string Source, string? Destination)> AdditionalMappings { get; set; } = Array.Empty<(string, string?)>();

    public VmrInfo(IProcessManager processManager, LocalPath vmrPath, LocalPath tmpPath)
    {
        VmrPath = vmrPath;
        TmpPath = tmpPath;
        _processManager = processManager;
    }

    public VmrInfo(IProcessManager processManager, string vmrPath, string tmpPath)
        : this(processManager, new NativePath(vmrPath), new NativePath(tmpPath))
    {
    }

    public UnixPath GetGitPath(LocalPath path)
    {
        var unixVmrPath = new UnixPath(VmrPath);
        var unixTargetPath = new UnixPath(path);

        if (unixTargetPath.Path.StartsWith(unixVmrPath.Path))
        {
            return new UnixPath(unixTargetPath.Path.Substring(unixVmrPath.Path.Length + 1));
        }

        return unixTargetPath;
    }

    public LocalPath GetRepoSourcesPath(SourceMapping mapping) => GetRepoSourcesPath(mapping.Name);

    public LocalPath GetRepoSourcesPath(string mappingName) => VmrPath / SourcesDir / mappingName;

    public static UnixPath GetRelativeRepoSourcesPath(SourceMapping mapping) => RelativeSourcesDir / mapping.Name;

    public LocalPath GetSourceManifestPath() => VmrPath / SourcesDir / SourceManifestFileName;

    public async Task<string> GetFileContent(LocalPath path, string revision = VmrManagerBase.HEAD, LocalPath? outputPath = null)
    {
        var gitPath = GetGitPath(path);

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

        var result = await _processManager.ExecuteGit(VmrPath, args);
        result.ThrowIfFailed($"Failed to read {gitPath} from a bare VMR at {revision}");

        return outputPath != null
            ? gitPath
            : result.StandardOutput;
    }

    public bool BareMode => true; // TODO
}
