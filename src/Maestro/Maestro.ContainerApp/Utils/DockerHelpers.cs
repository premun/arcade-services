// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp.Utils;

public static class DockerHelpers
{
    public static bool IsDocker => Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true";
}
