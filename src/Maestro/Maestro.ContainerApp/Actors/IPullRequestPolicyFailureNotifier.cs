// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.


using System.Threading.Tasks;

namespace Maestro.ContainerApp.Actors;

public interface IPullRequestPolicyFailureNotifier
{
    Task TagSourceRepositoryGitHubContactsAsync(InProgressPullRequest pr);
}