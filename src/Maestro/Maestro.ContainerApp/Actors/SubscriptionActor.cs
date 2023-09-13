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
    private readonly BuildAssetRegistryContext _context;
    private readonly ILogger<SubscriptionActor> _logger;
    private readonly IActorFactory _actorFactory;
    private readonly Guid _subscriptionId;

    public SubscriptionActor(
        BuildAssetRegistryContext context,
        ILogger<SubscriptionActor> logger,
        IActorFactory actorFactory,
        Guid subscriptionId)
    {
        _context = context;
        _logger = logger;
        _actorFactory = actorFactory;
        _subscriptionId = subscriptionId;
    }

    public async Task UpdateAsync(int buildId)
    {
        Subscription? subscription = await _context.Subscriptions.FindAsync(_subscriptionId);

        await AddDependencyFlowEventAsync(
            buildId,
            DependencyFlowEventType.Fired,
            DependencyFlowEventReason.New,
            MergePolicyCheckResult.PendingPolicies,
            "PR",
            null);

        _logger.LogInformation($"Looking up build {buildId}");

        Build build = await _context.Builds.Include(b => b.Assets)
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
            pullRequestActorId = new PullRequestActorId(_subscriptionId);
        }

        _logger.LogInformation($"Creating pull request actor for '{pullRequestActorId}'");

        IPullRequestActor pullRequestActor = await _actorFactory.CreatePullRequestActor(_subscriptionId);

        List<Asset> assets = build.Assets.Select(
                a => new Asset
                {
                    Name = a.Name,
                    Version = a.Version
                })
            .ToList();

        _logger.LogInformation($"Running asset update for {_subscriptionId}");

        await pullRequestActor.UpdateAssetsAsync(
            _subscriptionId,
            build.Id,
            build.GitHubRepository ?? build.AzureDevOpsRepository,
            build.Commit,
            assets);

        _logger.LogInformation($"Asset update complete for {_subscriptionId}");
        return;
    }

    public async Task<bool> UpdateForMergedPullRequestAsync(int updateBuildId)
    {
        _logger.LogInformation($"Updating {_subscriptionId} with latest build id {updateBuildId}");
        Subscription? subscription = await _context.Subscriptions.FindAsync(_subscriptionId);
        
        if (subscription != null)
        {
            subscription.LastAppliedBuildId = updateBuildId;
            _context.Subscriptions.Update(subscription);
            await _context.SaveChangesAsync();
            return true;
        }
        else
        {
            _logger.LogInformation($"Could not find subscription with ID {_subscriptionId}. Skipping latestBuild update.");
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

        _logger.LogInformation($"Adding dependency flow event for {_subscriptionId} with {flowEvent} {updateReason} {flowType}");
        Subscription? subscription = await _context.Subscriptions.FindAsync(_subscriptionId);
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
            _context.DependencyFlowEvents.Add(dfe);
            await _context.SaveChangesAsync();
            return true;
        }
        else
        {
            _logger.LogInformation($"Could not find subscription with ID {_subscriptionId}. Skipping adding dependency flow event.");
            return false;
        }
    }

    private async Task<SubscriptionUpdate> GetSubscriptionUpdate()
    {
        SubscriptionUpdate? subscriptionUpdate = await _context.SubscriptionUpdates.FindAsync(_subscriptionId);
        if (subscriptionUpdate == null)
        {
            _context.SubscriptionUpdates.Add(
                subscriptionUpdate = new SubscriptionUpdate {SubscriptionId = _subscriptionId});
        }
        else
        {
            _context.SubscriptionUpdates.Update(subscriptionUpdate);
        }

        return subscriptionUpdate;
    }
}
