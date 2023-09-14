// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text.Json.Serialization;
using Maestro.ContainerApp.Actors;

namespace Maestro.ContainerApp.Queues.WorkItems;

public class PullRequestReminderWorkItem : BackgroundWorkItem
{
    public PullRequestReminderWorkItem(string name, PullRequestActorId actorId)
    {
        Name = name;

        if (actorId.IdKind == ActorIdKind.Guid)
        {
            SubscriptionId = Guid.Parse(actorId.Id);
        }
        if (actorId.IdKind == ActorIdKind.String)
        {
            (Repository, Branch) = actorId.Parse();
        }
    }

    [JsonConstructor]
    public PullRequestReminderWorkItem(string name, string? repository, string? branch, Guid? subscriptionId)
    {
        Name = name;
        Repository = repository;
        Branch = branch;
        SubscriptionId = subscriptionId;
    }

    public string Name { get; set; }

    public string? Repository { get; set; }

    public string? Branch { get; set; }

    public Guid? SubscriptionId { get; set; }
}
