// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.AzureDevOps;
using Maestro.ContainerApp;
using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Utils;
using Maestro.Contracts;
using Maestro.Data;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.GitHub.Authentication;
using Microsoft.DotNet.Internal.Logging;
using Microsoft.DotNet.Kusto;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Internal;
using Microsoft.Extensions.Logging.Console;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddLogging(b =>
    b.AddConsole(options =>
        options.FormatterName = SimpleConsoleLoggerFormatter.FormatterName)
     .AddConsoleFormatter<SimpleConsoleLoggerFormatter, SimpleConsoleFormatterOptions>(
        options => options.TimestampFormat = "[HH:mm:ss] "));

builder.AddBackgroudQueueProcessors();

builder.Services.AddTransient<IActorFactory, ActorFactory>();
builder.Services.AddTransient<DarcRemoteMemoryCache>();
builder.Services.AddTransient<Microsoft.DotNet.Services.Utility.ExponentialRetry>();
builder.Services.AddTransient<IAzureDevOpsTokenProvider, AzureDevOpsTokenProvider>();
builder.Services.AddTransient<IBarClient, MaestroBarClient>();
builder.Services.AddTransient<IDependencyUpdater, DependencyUpdater>();
builder.Services.AddTransient<IGitHubAppTokenProvider, GitHubAppTokenProvider>();
builder.Services.AddTransient<IGitHubClientFactory, GitHubClientFactory>();
builder.Services.AddTransient<IGitHubTokenProvider, GitHubTokenProvider>();
builder.Services.AddTransient<IInstallationLookup, InMemoryCacheInstallationLookup>();
builder.Services.AddTransient<ILocalGit, LocalGit>();
builder.Services.AddTransient<IMergePolicyEvaluator, MergePolicyEvaluator>();
builder.Services.AddTransient<IPullRequestPolicyFailureNotifier, PullRequestPolicyFailureNotifier>();
builder.Services.AddTransient<IRemoteFactory, DarcRemoteFactory>();
builder.Services.AddTransient<ISystemClock, SystemClock>();
builder.Services.AddTransient<IVersionDetailsParser, VersionDetailsParser>();
builder.Services.AddTransient<OperationManager>();
builder.Services.AddTransient<TemporaryFiles>();
builder.Services.AddSingleton<IInstallationLookup, BuildAssetRegistryInstallationLookup>();
builder.Services.AddSingleton<TemporaryFiles>();
builder.Services.AddKustoClientProvider("Kusto");
builder.Services.AddGitHubTokenProvider();

// SQL
builder.Services.AddDbContext<BuildAssetRegistryContext>(options => options.UseSqlServer(builder.GetConnectionString("BuildAssetRegistry")));

// Redis
builder.Services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(builder.GetConnectionString("Redis")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();

