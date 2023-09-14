// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Queues.WorkItems;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal class SubscriptionActorActionQueueProcessor : QueueProcessor<SubscriptionActorActionWorkItem>
{
    private readonly IActorFactory _actorFactory;

    public SubscriptionActorActionQueueProcessor(
        IActorFactory actorFactory,
        ILogger<SubscriptionActorActionQueueProcessor> logger)
        : base(logger)
    {
        _actorFactory = actorFactory;
    }

    protected override Task ProcessAsyncInternal(SubscriptionActorActionWorkItem workItem, CancellationToken cancellationToken)
    {
        // TODO
        throw new NotImplementedException();
    }
}
