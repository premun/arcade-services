// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.Contracts;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal class StartSubscriptionUpdateQueueProcess : QueueProcessor<StartSubscriptionUpdateWorkItem>
{
    private readonly IDependencyUpdater _dependencyUpdater;

    public StartSubscriptionUpdateQueueProcess(IDependencyUpdater dependencyUpdater, ILogger logger)
        : base(logger)
    {
        _dependencyUpdater = dependencyUpdater;
    }

    protected override async Task ProcessAsyncInternal(StartSubscriptionUpdateWorkItem workItem, CancellationToken cancellationToken)
    {
        if (workItem.BuildId != 0)
        {
            await _dependencyUpdater.StartSubscriptionUpdateForSpecificBuildAsync(
                workItem.SubscriptionId,
                workItem.BuildId);
        }
        else
        {
            await _dependencyUpdater.StartSubscriptionUpdateAsync(workItem.SubscriptionId);
        }
    }
}
