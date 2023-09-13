// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.AzureDevOps;
using Maestro.DataProviders;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.GitHub.Authentication;
using Microsoft.DotNet.Internal.Logging;
using Microsoft.DotNet.Kusto;
using Microsoft.DotNet.Services.Utility;
using Microsoft.Extensions.Internal;

namespace Maestro.ContainerApp.Api.Controllers;

internal static class ControllerConfiguration
{
    public static void AddControllerConfigurations(this WebApplicationBuilder builder)
    {
        builder.Services.AddSingleton<IGitHubClientFactory, GitHubClientFactory>();
        builder.Services.AddScoped<IRemoteFactory, DarcRemoteFactory>();
        builder.Services.AddKustoClientProvider("Kusto");
        builder.Services.AddGitHubTokenProvider();
        builder.Services.AddSingleton<ISystemClock, SystemClock>();
        builder.Services.AddSingleton<ExponentialRetry>();
        builder.Services.AddSingleton<IAzureDevOpsTokenProvider, AzureDevOpsTokenProvider>();
        builder.Services.Configure<AzureDevOpsTokenProviderOptions>(
            (options, provider) =>
            {
                var tokenMap = builder.Configuration.GetSection("AzureDevOps:Tokens").GetChildren();
                foreach (IConfigurationSection token in tokenMap)
                {
                    options.Tokens.Add(token.GetValue<string>("Account"), token.GetValue<string>("Token"));
                }
            });
        builder.Services.AddTransient<IVersionDetailsParser, VersionDetailsParser>();
        builder.Services.AddSingleton<DarcRemoteMemoryCache>();
        builder.Services.AddSingleton<OperationManager>();
        builder.Services.Configure<OperationManagerOptions>(_ => new OperationManagerOptions());
    }
}
