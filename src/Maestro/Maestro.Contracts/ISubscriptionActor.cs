// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Threading.Tasks;

namespace Maestro.Contracts;

public interface ISubscriptionActor
{
    Task<string> RunActionAsync(string method, string arguments);
    Task UpdateAsync(int buildId);
    Task<bool> UpdateForMergedPullRequestAsync(int updateBuildId);
    Task<bool> AddDependencyFlowEventAsync(int updateBuildId, DependencyFlowEventType flowEvent, DependencyFlowEventReason reason, MergePolicyCheckResult policy, string flowType, string url);
}
