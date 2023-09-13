// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp.Actors;

public static class ActorRegistration
{
    public static void AddActors(this WebApplicationBuilder builder)
    {
        builder.Services.AddTransient<IActorFactory, ActorFactory>();
    }
}
