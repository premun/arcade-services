// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.AzureDevOps;
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
        builder.Services.AddTransient<IGitHubClientFactory, GitHubClientFactory>();
        builder.Services.AddTransient<IGitHubAppTokenProvider, GitHubAppTokenProvider>();
        builder.Services.AddTransient<IInstallationLookup, InMemoryCacheInstallationLookup>();
        builder.Services.AddTransient<IGitHubTokenProvider, GitHubTokenProvider>();
        builder.Services.AddTransient<IAzureDevOpsTokenProvider, AzureDevOpsTokenProvider>();
        builder.Services.AddTransient<DarcRemoteMemoryCache>();
        builder.Services.AddTransient<TemporaryFiles>();
        builder.Services.AddTransient<IBarClient, MaestroBarClient>();
        builder.Services.AddTransient<ILocalGit, LocalGit>();
        builder.Services.AddTransient<IRemoteFactory, DarcRemoteFactory>();
        builder.Services.AddKustoClientProvider("Kusto");
        builder.Services.AddGitHubTokenProvider();
        builder.Services.AddTransient<ISystemClock, SystemClock>();
        builder.Services.AddTransient<ExponentialRetry>();
        builder.Services.AddTransient<IVersionDetailsParser, VersionDetailsParser>();
        builder.Services.AddTransient<OperationManager>();
    }
}
