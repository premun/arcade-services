// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.DotNet.DarcLib.Helpers;
using NUnit.Framework;

namespace Microsoft.DotNet.Darc.Tests.VirtualMonoRepo;

[TestFixture]
public class VmrPatchRemovingFileTest : VmrPatchesTestsBase
{
    public VmrPatchRemovingFileTest() : base("remove-file.patch")
    {
    }

    [Test]
    [TestCase(false)]
    [TestCase(true)]
    public async Task VmrPatchAddsFileTest(bool bareClone)
    {
        var patchPathInRepo = InstallerPatchesDir / PatchFileName;

        await InitializeRepoAtLastCommit(Constants.InstallerRepoName, InstallerRepoPath, bareClone);
        await InitializeRepoAtLastCommit(Constants.ProductRepoName, ProductRepoPath, bareClone);

        var expectedFilesFromRepos = new List<LocalPath>
        {
            VmrPatchesDir / PatchFileName,
            InstallerFilePathInVmr
        };

        var expectedFiles = GetExpectedFilesInVmr(
            VmrPath,
            new[] { Constants.ProductRepoName, Constants.InstallerRepoName },
            expectedFilesFromRepos);

        CheckDirectoryContents(VmrPath, expectedFiles);

        File.Delete(patchPathInRepo);
        await GitOperations.CommitAll(InstallerRepoPath, "Remove the patch file");
        await UpdateRepoToLastCommit(Constants.InstallerRepoName, InstallerRepoPath, bareClone);

        expectedFiles.Add(ProductRepoFilePathInVmr);
        expectedFiles.Remove(VmrPatchesDir / PatchFileName);

        CheckDirectoryContents(VmrPath, expectedFiles);
    }
}

