// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Data;
using Maestro.Data.Models;
using Microsoft.DotNet.DarcLib;
using StackExchange.Redis;

namespace Maestro.ContainerApp.Actors;

/// <summary>
///     A <see cref="PullRequestActorImplementation" /> that reads its Merge Policies and Target information from a
///     non-batched subscription object
/// </summary>
public class NonBatchedPullRequestActor : PullRequestActor
{
    private readonly Lazy<Task<Subscription>> _lazySubscription;
    private readonly PullRequestActorId _actorId;
    private readonly BuildAssetRegistryContext _dbContext;
    private readonly IPullRequestPolicyFailureNotifier _pullRequestPolicyFailureNotifier;
    private readonly IDatabase _redisCache;
    private readonly IReminderManager _reminders;

    public NonBatchedPullRequestActor(
        PullRequestActorId actorId,
        IMergePolicyEvaluator mergePolicyEvaluator,
        BuildAssetRegistryContext dbContext,
        IActorFactory actorFactory,
        IRemoteFactory darcFactory,
        ILoggerFactory loggerFactory,
        IPullRequestPolicyFailureNotifier pullRequestPolicyFailureNotifier,
        IConnectionMultiplexer redis,
        IReminderManager reminders)
        : base(actorId, mergePolicyEvaluator, dbContext, actorFactory, darcFactory, loggerFactory, redis, reminders)
    {
        _lazySubscription = new Lazy<Task<Subscription>>(RetrieveSubscription);
        _actorId = actorId;
        _dbContext = dbContext;
        _pullRequestPolicyFailureNotifier = pullRequestPolicyFailureNotifier;
        _redisCache = redis.GetDatabase();
        _reminders = reminders;
    }

    private async Task<Subscription> RetrieveSubscription()
    {
        Subscription? subscription = await _dbContext.Subscriptions.FindAsync(_actorId.Id);
        if (subscription == null)
        {
            await _redisCache.KeyDeleteAsync(PullRequestRedisKey);

            throw new SubscriptionException($"Subscription '{_actorId.Id}' was not found...");
        }

        return subscription;
    }

    private Task<Subscription> GetSubscription()
    {
        return _lazySubscription.Value;
    }
    protected override async Task TagSourceRepositoryGitHubContactsIfPossibleAsync(InProgressPullRequest pr)
    {
        await _pullRequestPolicyFailureNotifier.TagSourceRepositoryGitHubContactsAsync(pr);
    }

    protected override async Task<(string repository, string branch)> GetTargetAsync()
    {
        Subscription subscription = await GetSubscription();
        return (subscription.TargetRepository, subscription.TargetBranch);
    }

    protected override async Task<IReadOnlyList<MergePolicyDefinition>> GetMergePolicyDefinitions()
    {
        Subscription subscription = await GetSubscription();
        return (IReadOnlyList<MergePolicyDefinition>)subscription.PolicyObject.MergePolicies ??
               Array.Empty<MergePolicyDefinition>();
    }

    public override async Task<(InProgressPullRequest? pr, bool canUpdate)> SynchronizeInProgressPullRequestAsync()
    {
        Subscription subscription = await GetSubscription();
        if (subscription == null)
        {
            return (null, false);
        }

        return await base.SynchronizeInProgressPullRequestAsync();
    }
}
