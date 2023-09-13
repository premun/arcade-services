// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp.Queues.WorkItems;

internal class BuildCoherencyInfoWorkItem : BackgroundWorkItem
{
    public int BuildId { get; set; }
}
