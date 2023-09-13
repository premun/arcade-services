// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp.Queues.WorkItems;

public class SubscriptionActorActionWorkItem : BackgroundWorkItem
{
    public Guid Subscriptionid { get; set; }
    public string? Method { get; set; }
    public string? MethodArguments { get; set; }
}
