// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Contracts;
using Microsoft.ServiceFabric.Actors;

namespace Maestro.ContainerApp.Actors;

public interface ISubscriptionActor : IActor
{
    Task UpdateAsync(int buildId);
    Task<bool> UpdateForMergedPullRequestAsync(int updateBuildId);
    Task<bool> AddDependencyFlowEventAsync(
        int updateBuildId,
        DependencyFlowEventType flowEvent,
        DependencyFlowEventReason reason,
        MergePolicyCheckResult policy,
        string flowType,
        string url);
}
