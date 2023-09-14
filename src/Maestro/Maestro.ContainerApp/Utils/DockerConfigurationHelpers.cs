// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp.Utils;

public static class DockerConfigurationHelpers
{
    public static string GetConnectionString(this WebApplicationBuilder builder, string name)
    {
        var section = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true"
            ? builder.Configuration.GetSection("ConnectionStrings")
            : builder.Configuration.GetSection("ConnectionStringsNonDocker");

        return section[name] ?? throw new Exception($"Connection string {name} not found");
    }
}
