// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp;

public interface ILocalGit
{
    string GetPathToLocalGit();
}

public class LocalGit : ILocalGit
{
    public string GetPathToLocalGit()
    {
        var gitExePath = EnvironmentVariables.GIT_PATH_ENV_VAR_NAME;
        if (!File.Exists(gitExePath))
        {
            throw new InvalidOperationException(
                $"Portable git not found at path '{gitExePath}', the build needs to be configured to publish it inside the service package.");
        }

        return gitExePath;
    }
}
