// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Models.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.Helpers;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public interface IVmrInfo
{
    /// <summary>
    /// Path for temporary files (individual repo clones, created patches, etc.)
    /// </summary>
    LocalPath TmpPath { get; }

    /// <summary>
    /// Path to the root of the VMR
    /// </summary>
    LocalPath VmrPath { get; }

    /// <summary>
    /// Path within the VMR where VMR patches are stored.
    /// These patches are applied on top of the synchronized content.
    /// The Path is UNIX style and relative (e.g. "src/patches").
    /// </summary>
    string? PatchesPath { get; set; }

    /// <summary>
    /// Path to the source-mappings.json file 
    /// </summary>
    string? SourceMappingsPath { get; set; }

    /// <summary>
    /// Additionally mapped directories that are copied to non-src/ locations within the VMR.
    /// Paths are UNIX style and relative.
    /// Example: ("src/installer/eng/common", "eng/common")
    /// </summary>
    IReadOnlyCollection<(string Source, string? Destination)> AdditionalMappings { get; set; }

    /// <summary>
    /// Gets a UNIX-style relative path inside of the VMR from a given absolute path
    /// </summary>
    UnixPath GetGitPath(LocalPath path);

    /// <summary>
    /// Gets a full path leading to sources belonging to a given repo (mapping)
    /// </summary>
    LocalPath GetRepoSourcesPath(SourceMapping mapping);

    /// <summary>
    /// Gets a full path leading to sources belonging to a given repo
    /// </summary>
    LocalPath GetRepoSourcesPath(string mappingName);

    /// <summary>
    /// Gets a full path leading to the source manifest JSON file.
    /// </summary>
    LocalPath GetSourceManifestPath();

    /// <summary>
    /// Retrieves a file's content from VMR's git index.
    /// </summary>
    /// <param name="path">Absolute or relative path</param>
    /// <param name="revision">Revision to get the file from</param>
    /// <param name="outputPath">Optional path to write the contents to</param>
    /// <returns>File contents</returns>
    Task<string> GetFileContent(LocalPath path, string revision = VmrManagerBase.HEAD, LocalPath? outputPath = null);

    /// <summary>
    /// Work with repositories in bare mode (no working directory)
    /// </summary>
    public bool BareMode { get; }
}
