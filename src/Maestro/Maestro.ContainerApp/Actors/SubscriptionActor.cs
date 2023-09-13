// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Contracts;
using Maestro.Data;
using Maestro.Data.Models;
using Microsoft.EntityFrameworkCore;

using Asset = Maestro.Contracts.Asset;


namespace Maestro.ContainerApp.Actors;

public class SubscriptionActor : ISubscriptionActor
{
    public SubscriptionActor(
        BuildAssetRegistryContext context,
        ILogger<SubscriptionActor> logger,
        IActorFactory actorFactory,
        Guid subscriptionId)
    {
        Context = context;
        Logger = logger;
        ActorFactory = actorFactory;
        SubscriptionId = subscriptionId;
    }

    public BuildAssetRegistryContext Context { get; }
    public ILogger<SubscriptionActor> Logger { get; }

    public IActorFactory ActorFactory { get; }

    public Guid SubscriptionId { get; }

    public async Task UpdateAsync(int buildId)
    {
        Subscription? subscription = await Context.Subscriptions.FindAsync(SubscriptionId);

        await AddDependencyFlowEventAsync(
            buildId,
            DependencyFlowEventType.Fired,
            DependencyFlowEventReason.New,
            MergePolicyCheckResult.PendingPolicies,
            "PR",
            null);

        Logger.LogInformation($"Looking up build {buildId}");

        Build build = await Context.Builds.Include(b => b.Assets)
            .ThenInclude(a => a.Locations)
            .FirstAsync(b => b.Id == buildId);

        PullRequestActorId pullRequestActorId;

        if (subscription != null && subscription.PolicyObject.Batchable)
        {
            pullRequestActorId = new PullRequestActorId(
                subscription.TargetRepository,
                subscription.TargetBranch);
        }
        else
        {
            pullRequestActorId = new PullRequestActorId(SubscriptionId);
        }

        Logger.LogInformation($"Creating pull request actor for '{pullRequestActorId}'");

        IPullRequestActor pullRequestActor = await ActorFactory.CreatePullRequestActor(SubscriptionId);

        List<Asset> assets = build.Assets.Select(
                a => new Asset
                {
                    Name = a.Name,
                    Version = a.Version
                })
            .ToList();

        Logger.LogInformation($"Running asset update for {SubscriptionId}");

        await pullRequestActor.UpdateAssetsAsync(
            SubscriptionId,
            build.Id,
            build.GitHubRepository ?? build.AzureDevOpsRepository,
            build.Commit,
            assets);

        Logger.LogInformation($"Asset update complete for {SubscriptionId}");
        return;
    }

    public async Task<bool> UpdateForMergedPullRequestAsync(int updateBuildId)
    {
        Logger.LogInformation($"Updating {SubscriptionId} with latest build id {updateBuildId}");
        Subscription? subscription = await Context.Subscriptions.FindAsync(SubscriptionId);
        
        if (subscription != null)
        {
            subscription.LastAppliedBuildId = updateBuildId;
            Context.Subscriptions.Update(subscription);
            await Context.SaveChangesAsync();
            return true;
        }
        else
        {
            Logger.LogInformation($"Could not find subscription with ID {SubscriptionId}. Skipping latestBuild update.");
            return false;
        }
    }

    public async Task<bool> AddDependencyFlowEventAsync(
        int updateBuildId, 
        DependencyFlowEventType flowEvent, 
        DependencyFlowEventReason reason, 
        MergePolicyCheckResult policy,
        string flowType,
        string? url)
    {
        string updateReason = reason == DependencyFlowEventReason.New || 
                              reason == DependencyFlowEventReason.AutomaticallyMerged ? 
                             reason.ToString() : $"{reason.ToString()}{policy.ToString()}";

        Logger.LogInformation($"Adding dependency flow event for {SubscriptionId} with {flowEvent} {updateReason} {flowType}");
        Subscription? subscription = await Context.Subscriptions.FindAsync(SubscriptionId);
        if (subscription != null)
        {
            DependencyFlowEvent dfe = new DependencyFlowEvent { 
                    SourceRepository = subscription.SourceRepository,
                    TargetRepository = subscription.TargetRepository,
                    ChannelId = subscription.ChannelId,
                    BuildId = updateBuildId,
                    Timestamp = DateTimeOffset.UtcNow,
                    Event = flowEvent.ToString(),
                    Reason = updateReason,
                    FlowType = flowType,
                    Url = url
                    };
            Context.DependencyFlowEvents.Add(dfe);
            await Context.SaveChangesAsync();
            return true;
        }
        else
        {
            Logger.LogInformation($"Could not find subscription with ID {SubscriptionId}. Skipping adding dependency flow event.");
            return false;
        }
    }

    private async Task<SubscriptionUpdate> GetSubscriptionUpdate()
    {
        SubscriptionUpdate? subscriptionUpdate = await Context.SubscriptionUpdates.FindAsync(SubscriptionId);
        if (subscriptionUpdate == null)
        {
            Context.SubscriptionUpdates.Add(
                subscriptionUpdate = new SubscriptionUpdate {SubscriptionId = SubscriptionId});
        }
        else
        {
            Context.SubscriptionUpdates.Update(subscriptionUpdate);
        }

        return subscriptionUpdate;
    }
}
