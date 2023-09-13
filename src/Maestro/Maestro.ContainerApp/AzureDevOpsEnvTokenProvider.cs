// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.AzureDevOps;

namespace Maestro.ContainerApp;

public class AzureDevOpsEnvTokenProvider : IAzureDevOpsTokenProvider
{
    // one token returned for all accounts
    public Task<string> GetTokenForAccount(string account)
    {
        const string TOKEN_VAR_NAME = "HACKATHON-AZDO-TOKEN";
        return Task.Run(
            () =>
            {
                string? token = Environment.GetEnvironmentVariable(TOKEN_VAR_NAME);
                if (token == null)
                {
                    throw new Exception($"Environment variable '{TOKEN_VAR_NAME}' not defined.");
                }
                return token;
            }
        );
    }
}
