// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text.Json.Serialization;

namespace Maestro.ContainerApp.Queues.WorkItems;

[JsonDerivedType(typeof(StartSubscriptionUpdateWorkItem), typeDiscriminator: nameof(StartSubscriptionUpdateWorkItem))]
[JsonDerivedType(typeof(BuildCoherencyInfoWorkItem), typeDiscriminator: nameof(BuildCoherencyInfoWorkItem))]
[JsonDerivedType(typeof(CheckDailySubscriptionsWorkItem), typeDiscriminator: nameof(CheckDailySubscriptionsWorkItem))]
[JsonDerivedType(typeof(SubscriptionActorActionWorkItem), typeDiscriminator: nameof(SubscriptionActorActionWorkItem))]
[JsonDerivedType(typeof(PullRequestCheckWorkItem), typeDiscriminator: nameof(PullRequestCheckWorkItem))]
public abstract class BackgroundWorkItem
{
    public Guid WorkItemId { get; set; } = Guid.NewGuid();
}
