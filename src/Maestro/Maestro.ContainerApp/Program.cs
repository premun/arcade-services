// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Reflection;
using System.Text.Json.Serialization;
using Maestro.AzureDevOps;
using Maestro.ContainerApp;
using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Utils;
using Maestro.Contracts;
using Maestro.Data;
using Microsoft.DncEng.Configuration.Extensions;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.GitHub.Authentication;
using Microsoft.DotNet.Internal.Logging;
using Microsoft.DotNet.Kusto;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Internal;
using Microsoft.Extensions.Logging.Console;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Configuration
#pragma warning disable ASP0000 // Do not call 'IServiceCollection.BuildServiceProvider' in 'ConfigureServices'
builder.Configuration.AddDefaultJsonConfiguration(builder.Environment, new ServiceCollection().BuildServiceProvider());
#pragma warning restore ASP0000 // Do not call 'IServiceCollection.BuildServiceProvider' in 'ConfigureServices'
builder.Services.Configure<GitHubTokenProviderOptions>(builder.Configuration.GetSection("GitHub"));
builder.Services.Configure<GitHubClientOptions>(options =>
{
    options.ProductHeader = new Octokit.ProductHeaderValue(
        "Maestro",
        Assembly.GetEntryAssembly()!.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion);
});

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        var enumConverter = new JsonStringEnumConverter();
        options.JsonSerializerOptions.Converters.Add(enumConverter);
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter(System.Text.Json.JsonNamingPolicy.CamelCase));
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

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
builder.Services.AddTransient<IBarClient, MaestroBarClient>();
builder.Services.AddTransient<IDependencyUpdater, DependencyUpdater>();
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
builder.Services.AddSingleton<IInstallationLookup, BuildAssetRegistryInstallationLookup>();
builder.Services.AddSingleton<TemporaryFiles>();
builder.Services.AddKustoClientProvider("Kusto");

// Tokens
builder.Services.AddGitHubTokenProvider();
builder.Services.AddTransient<IAzureDevOpsTokenProvider, AzureDevOpsTokenProvider>();
builder.Services.Configure<AzureDevOpsTokenProviderOptions>(
    (options, provider) =>
    {
        var tokenMap = builder.Configuration.GetSection("AzureDevOps:Tokens").GetChildren();
        foreach (IConfigurationSection token in tokenMap)
        {
            options.Tokens.Add(token.GetValue<string>("Account"), token.GetValue<string>("Token"));
        }
    });

// SQL
builder.Services.AddDbContext<BuildAssetRegistryContext>(options =>
{
    options.UseSqlServer(builder.GetConnectionString("BuildAssetRegistry"));

    // Silence query execution logs
    options.ConfigureWarnings(b => b.Log((RelationalEventId.CommandExecuted, LogLevel.Trace)));
});

// Redis
builder.Services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect(builder.GetConnectionString("Redis")));

builder.Services.AddSingleton<IReminderManager, ReminderManager>();

var app = builder.Build();

app.UseHttpLogging();

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

