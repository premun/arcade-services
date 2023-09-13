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
public class NonBatchedPullRequestActorImplementation : PullRequestActor
{
    private readonly Lazy<Task<Subscription>> _lazySubscription;
    private readonly IPullRequestPolicyFailureNotifier _pullRequestPolicyFailureNotifier;

    public NonBatchedPullRequestActorImplementation(
        PullRequestActorId actorId,
        IMergePolicyEvaluator mergePolicyEvaluator,
        BuildAssetRegistryContext context,
        IActorFactory actorFactory,
        IRemoteFactory darcFactory,
        ILoggerFactory loggerFactory,
        IPullRequestPolicyFailureNotifier pullRequestPolicyFailureNotifier,
        IConnectionMultiplexer redis) : base(
            actorId,
            mergePolicyEvaluator,
            context,
            actorFactory,
            darcFactory,
            loggerFactory,
            redis)
    {
        _lazySubscription = new Lazy<Task<Subscription>>(RetrieveSubscription);
        _pullRequestPolicyFailureNotifier = pullRequestPolicyFailureNotifier;
    }

    private async Task<Subscription> RetrieveSubscription()
    {
        Subscription? subscription = await Context.Subscriptions.FindAsync(ActorId.Id);
        if (subscription == null)
        {
            await Db.KeyDeleteAsync(PullRequestRedisKey);

            throw new SubscriptionException($"Subscription '{ActorId.Id}' was not found...");
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
