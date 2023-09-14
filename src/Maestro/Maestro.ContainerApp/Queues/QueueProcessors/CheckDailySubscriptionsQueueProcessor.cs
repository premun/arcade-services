// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.Contracts;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal class CheckDailySubscriptionsQueueProcessor : QueueProcessor<CheckDailySubscriptionsWorkItem>
{
    private readonly IDependencyUpdater _dependencyUpdater;

    public CheckDailySubscriptionsQueueProcessor(
        IDependencyUpdater dependencyUpdater,
        ILogger<CheckDailySubscriptionsQueueProcessor> logger)
        : base(logger)
    {
        _dependencyUpdater = dependencyUpdater;
    }

    protected override async Task ProcessAsyncInternal(CheckDailySubscriptionsWorkItem workItem, CancellationToken cancellationToken)
    {
        await _dependencyUpdater.CheckDailySubscriptionsAsync(cancellationToken);
    }
}
