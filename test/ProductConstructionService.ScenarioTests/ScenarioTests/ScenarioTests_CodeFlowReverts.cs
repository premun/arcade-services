// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Kusto.Data.Common;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.DotNet.DarcLib.VirtualMonoRepo;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using NUnit.Framework;

namespace ProductConstructionService.ScenarioTests;

[TestFixture]
[Category("PostDeployment")]
[Category("CodeFlow")]
internal partial class ScenarioTests_CodeFlow : CodeFlowScenarioTestBase
{
    /*
        This test verifies a scenario where a file is changed (added, removed, edited) and later reverted
        while there are unrelated conflicts at the same time.
        More details about this in https://github.com/dotnet/arcade-services/issues/5046

            repo                   VMR
              O────────────────────►O 0. 
              │                 2.  │\
            1.O─────────────────O   │ \__
              │                 │   │    \
              │                 └──►O 3.  \
              │                     │      O 5. FF branch
            4.O─────────────────x   │      
              │                  5. │

        1. Files undergo their change in the repo
        2. FF is opened and in the PR branch, we change the file that will cause a conflict later
        3. FF PR is merged
        4. Reverts of changes are made in the repo
        5. The next forward flow will conflict
           This means the FF branch will be based on 0 and previous flow (1->3) will be recreated there.
           This means the FF branch needs to have all the changes from the repo (1-4).
           BUT the reverts won't be part of the branch's changes because they nullify the changes.
           That means the PR branch won't technically manifest the reverts and when it's merged,
           the VMR will retain the unreverted changes.
    */
    [Test]
    public async Task Vmr_ForwardFlowWithRevertsTest()
    {
        var channelName = GetTestChannelName();
        var branchName = GetTestBranchName();
        var targetBranchName = GetTestBranchName();

        // Name of the branch that is already in the test repos and has the contents we need
        const string BaseBranchName = "Vmr_ForwardFlowWithRevertsTest";

        const string PartialRevertChange1 =
            """
            One
            Two
            Three
            Four
            Five
            Six
            Seven
            Eight
            Nine
            Ten
            111111111111
            """;

        const string PartialRevertChange2 =
            """
            One
            22222222222
            Three
            Four
            Five
            Six
            Seven
            Eight
            Nine
            Ten
            """;

        await using AsyncDisposableValue<string> testChannel = await CreateTestChannelAsync(channelName);
        await using AsyncDisposableValue<string> subscriptionId = await CreateForwardFlowSubscriptionAsync(
            channelName,
            TestRepository.TestRepo1Name,
            TestRepository.VmrTestRepoName,
            targetBranchName,
            UpdateFrequency.None.ToString(),
            TestParameters.GitHubTestOrg,
            targetDirectory: TestRepository.TestRepo1Name);

        TemporaryDirectory vmrDirectory = await CloneRepositoryAsync(TestRepository.VmrTestRepoName);
        TemporaryDirectory reposFolder = await CloneRepositoryAsync(TestRepository.TestRepo1Name);

        const string FileAddedAndRemovedName = "FileAddedAndRemoved.txt";
        const string FileRemovedAndAddedName = "FileRemovedAndAdded.txt";
        const string FileChangedAndPartiallyRevertedName = "FileChangedAndPartiallyReverted.txt";
        const string FileInConflictName = "FileInConflict.txt";

        var repoPath = new NativePath(reposFolder.Directory);
        var vmrRepoPath = new NativePath(vmrDirectory.Directory) / VmrInfo.SourceDirName / TestRepository.TestRepo1Name;

        // Create test branches off of the right base branch
        {
            using var _ = ChangeDirectory(vmrRepoPath);
            await CheckoutRemoteBranchAsync(BaseBranchName);
            using var __ = ChangeDirectory(repoPath);
            await CheckoutRemoteBranchAsync(BaseBranchName);
        }

        await CreateTargetBranchAndExecuteTest(targetBranchName, vmrDirectory.Directory, async () =>
        {
            using (ChangeDirectory(reposFolder.Directory))
            {
                await using (await CheckoutBranchAsync(branchName))
                {
                    // Make changes in the repo
                    TestContext.WriteLine("Preparing changes in the repo");
                    await File.WriteAllTextAsync(repoPath / FileInConflictName, "This file will cause a conflict");
                    await File.WriteAllTextAsync(repoPath / FileAddedAndRemovedName, "This file will be added and then removed");
                    await File.WriteAllTextAsync(repoPath / FileChangedAndPartiallyRevertedName, PartialRevertChange1);
                    string originalContent = await File.ReadAllTextAsync(repoPath / FileRemovedAndAddedName);
                    File.Delete(repoPath / FileRemovedAndAddedName);

                    await GitAddAllAsync();
                    await GitCommitAsync("Make changes which will get reverted later");

                    // Push it to github
                    await using (await PushGitBranchAsync("origin", branchName))
                    {
                        var repoSha = (await GitGetCurrentSha()).TrimEnd();

                        // Create a new build from the commit and add it to a channel
                        Build build = await CreateBuildAsync(
                            GetGitHubRepoUrl(TestRepository.TestRepo1Name),
                            branchName,
                            repoSha,
                            "1",
                            []);

                        TestContext.WriteLine("Adding build to channel");
                        await AddBuildToChannelAsync(build.Id, channelName);

                        TestContext.WriteLine("Triggering the subscription");
                        await TriggerSubscriptionAsync(subscriptionId.Value);

                        TestContext.WriteLine("Waiting for the PR to show up");
                        Octokit.PullRequest pr = await WaitForPullRequestAsync(TestRepository.VmrTestRepoName, targetBranchName);

                        // Now make a change directly in the PR
                        using (ChangeDirectory(vmrDirectory.Directory))
                        {
                            TestContext.WriteLine("Inserting a future conflict in the PR branch");
                            await CheckoutRemoteRefAsync(pr.Head.Ref);
                            await File.WriteAllTextAsync(vmrRepoPath / FileInConflictName, "Causing a conflict by a change in the FF PR");
                            await GitAddAllAsync();
                            await GitCommitAsync("Edit files in PR");
                            await PushGitBranchAsync("origin", pr.Head.Ref);
                        }

                        // Merge the PR
                        await MergePullRequestAsync(TestRepository.VmrTestRepoName, pr);

                        // Now we make changes in the repo that revert some of the previous changes + cause the conflict
                        TestContext.WriteLine("Preparing reverts of the changes and the conflict");
                        await File.WriteAllTextAsync(repoPath / FileRemovedAndAddedName, originalContent);
                        await File.WriteAllTextAsync(repoPath / FileChangedAndPartiallyRevertedName, PartialRevertChange2);
                        await File.WriteAllTextAsync(repoPath / FileInConflictName, "Causing a conflict by a change in the repo");
                        File.Delete(repoPath / FileAddedAndRemovedName);

                        await GitAddAllAsync();
                        await GitCommitAsync("Revert changes");
                        await RunGitAsync("push");

                        repoSha = (await GitGetCurrentSha()).TrimEnd();
                        TestContext.WriteLine("Creating a build from the new commit");
                        build = await CreateBuildAsync(
                            GetGitHubRepoUrl(TestRepository.TestRepo1Name),
                            branchName,
                            repoSha,
                            "2",
                            []);

                        TestContext.WriteLine("Adding build to channel");
                        await AddBuildToChannelAsync(build.Id, channelName);

                        TestContext.WriteLine("Triggering the subscription");
                        await TriggerSubscriptionAsync(subscriptionId.Value);

                        TestContext.WriteLine("Waiting for conflict comment to show up on the PR");
                        pr = await WaitForPullRequestComment(TestRepository.VmrTestRepoName, targetBranchName, "conflict");

                        // TODO: Wait for the new Maestro check to appear

                        // Merge the target branch into the PR branch
                        using (ChangeDirectory(vmrDirectory.Directory))
                        {
                            await MergeRemoteBranchesAsync(targetBranchName, pr.Head.Ref);
                        }

                        // TODO: Wait for the Maestro check to go green and a comment to appear
                    }
                }
            }
        });
    }
}
