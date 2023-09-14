// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Data;
using Maestro.Data.Models;
using Microsoft.DotNet.DarcLib;
using StackExchange.Redis;

namespace Maestro.ContainerApp.Actors;

/// <summary>
///     A <see cref="PullRequestActorImplementation" /> for batched subscriptions that reads its Target and Merge Policies
///     from the configuration for a repository
/// </summary>
public class BatchedPullRequestActor : PullRequestActor
{
    private readonly PullRequestActorId _actorId;
    private readonly BuildAssetRegistryContext _context;

    public BatchedPullRequestActor(
        PullRequestActorId actorId,
        IMergePolicyEvaluator mergePolicyEvaluator,
        BuildAssetRegistryContext context,
        IActorFactory actorFactory,
        IRemoteFactory darcFactory,
        ILoggerFactory loggerFactory,
        IConnectionMultiplexer redis,
        IReminderManager reminders)
        : base(actorId, mergePolicyEvaluator, context, actorFactory, darcFactory, loggerFactory, redis, reminders)
    {
        _actorId = actorId;
        _context = context;
    }

    protected override Task<(string repository, string branch)> GetTargetAsync()
    {
        var target = _actorId.Parse();
        return Task.FromResult((target.repository, target.branch));
    }

    protected override async Task<IReadOnlyList<MergePolicyDefinition>> GetMergePolicyDefinitions()
    {
        var target = _actorId.Parse();
        RepositoryBranch? repositoryBranch =
            await _context.RepositoryBranches.FindAsync(target.repository, target.branch);

        return repositoryBranch?.PolicyObject?.MergePolicies as IReadOnlyList<MergePolicyDefinition> ?? Array.Empty<MergePolicyDefinition>();
    }
}
