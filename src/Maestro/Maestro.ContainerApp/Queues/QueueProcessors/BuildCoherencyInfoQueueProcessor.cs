// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.Data;
using Microsoft.DotNet.DarcLib;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal class BuildCoherencyInfoQueueProcessor : QueueProcessor<BuildCoherencyInfoWorkItem>
{
    private readonly BuildAssetRegistryContext _dbContext;
    private readonly IRemoteFactory _remoteFactory;
    private readonly ILogger<BuildCoherencyInfoQueueProcessor> _logger;

    public BuildCoherencyInfoQueueProcessor(
        BuildAssetRegistryContext dbContext,
        IRemoteFactory remoteFactory,
        ILogger<BuildCoherencyInfoQueueProcessor> logger)
        : base(logger)
    {
        _dbContext = dbContext;
        _remoteFactory = remoteFactory;
        _logger = logger;
    }

    // This method is called asynchronously whenever a new build is inserted in BAR.
    // It's goal is to compute the incoherent dependencies that the build have and
    // persist the list of them in BAR.
    protected override async Task ProcessAsyncInternal(
        BuildCoherencyInfoWorkItem item,
        CancellationToken cancellationToken)
    {
        var graphBuildOptions = new DependencyGraphBuildOptions()
        {
            IncludeToolset = false,
            LookupBuilds = false,
            NodeDiff = NodeDiff.None
        };

        try
        {
            Data.Models.Build? build = await _dbContext.Builds.FindAsync(new object?[] { item.BuildId }, cancellationToken)
                ?? throw new Exception("TODO: this must be improved");

            DependencyGraph graph = await DependencyGraph.BuildRemoteDependencyGraphAsync(
                _remoteFactory,
                build.GitHubRepository ?? build.AzureDevOpsRepository,
                build.Commit,
                graphBuildOptions,
                _logger);

            var incoherencies = new List<Data.Models.BuildIncoherence>();

            foreach (var incoherence in graph.IncoherentDependencies)
            {
                incoherencies.Add(new Data.Models.BuildIncoherence
                {
                    Name = incoherence.Name,
                    Version = incoherence.Version,
                    Repository = incoherence.RepoUri,
                    Commit = incoherence.Commit
                });
            }

            _dbContext.Entry(build).Reload();
            build.Incoherencies = incoherencies;

            _dbContext.Builds.Update(build);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (Exception e)
        {
            _logger.LogWarning(e, $"Problems computing the dependency incoherencies for BAR build {item.BuildId}");
        }
    }
}
