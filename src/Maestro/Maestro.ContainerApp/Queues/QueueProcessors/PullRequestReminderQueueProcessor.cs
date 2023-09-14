// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.Contracts;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal class PullRequestReminderQueueProcessor : QueueProcessor<PullRequestReminderWorkItem>
{
    private readonly IActorFactory _actorFactory;

    public PullRequestReminderQueueProcessor(ILogger<PullRequestReminderQueueProcessor> logger, IActorFactory actorFactory) : base(logger)
    {
        _actorFactory = actorFactory;
    }

    protected override async Task ProcessAsyncInternal(PullRequestReminderWorkItem workItem, CancellationToken cancellationToken)
    {
        IPullRequestActor pullRequestActor;
        if (workItem.Repository != null && workItem.Branch != null)
        {
            pullRequestActor = _actorFactory.CreatePullRequestActor(workItem.Repository, workItem.Branch);
        }
        else if (workItem.SubscriptionId != null)
        {
            pullRequestActor = _actorFactory.CreatePullRequestActor(workItem.SubscriptionId.Value);
        }
        else
        {
            throw new ArgumentException("Cannot create PullRequestActor, ActorId is invalid");
        }

        if (workItem.Name.Contains(PullRequestActor.PullRequestCheckReminderPrefix))
        {
            await pullRequestActor.SynchronizeInProgressPullRequestAsync();
        }
        else if (workItem.Name.Contains(PullRequestActor.PullRequestUpdateReminderPrefix))
        {
            await pullRequestActor.ProcessPendingUpdatesAsync();
        }
    }
}
