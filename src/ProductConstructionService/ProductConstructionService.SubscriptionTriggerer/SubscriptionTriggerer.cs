// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Data;
using Maestro.Data.Models;
using Maestro.Data.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProductConstructionService.DependencyFlow.WorkItems;
using ProductConstructionService.WorkItems;

namespace ProductConstructionService.SubscriptionTriggerer;

public class SubscriptionTriggerer
{
    private readonly ILogger<SubscriptionTriggerer> _logger;
    private readonly BuildAssetRegistryContext _context;
    private readonly ISubscriptionService _subscriptionService;
    private readonly IWorkItemProducerFactory _workItemProducerFactory;

    public SubscriptionTriggerer(
        ILogger<SubscriptionTriggerer> logger,
        BuildAssetRegistryContext context,
        ISubscriptionService subscriptionService,
        IWorkItemProducerFactory workItemProducerFactory)
    {
        _logger = logger;
        _context = context;
        _subscriptionService = subscriptionService;
        _workItemProducerFactory = workItemProducerFactory;
    }

    public async Task TriggerSubscriptionsAsync(UpdateFrequency targetUpdateFrequency)
    {
        foreach (var updateSubscriptionWorkItem in await GetSubscriptionsToTrigger(targetUpdateFrequency))
        {
            await _workItemProducerFactory.CreateProducer<SubscriptionTriggerWorkItem>(updateSubscriptionWorkItem.sourceEnabled)
                .ProduceWorkItemAsync(updateSubscriptionWorkItem.item);
            _logger.LogInformation("Queued update for subscription '{subscriptionId}' with build '{buildId}'",
                    updateSubscriptionWorkItem.item.SubscriptionId,
                    updateSubscriptionWorkItem.item.BuildId);
        }
    }

    private async Task<List<(bool sourceEnabled, SubscriptionTriggerWorkItem item)>> GetSubscriptionsToTrigger(UpdateFrequency targetUpdateFrequency)
    {
        List<(bool, SubscriptionTriggerWorkItem)> subscriptionsToTrigger = [];

        var enabledSubscriptionsWithTargetFrequency = (await _subscriptionService.GetSubscriptionsAsync())
                .Where(s => s.Enabled && s.PolicyObject?.UpdateFrequency == targetUpdateFrequency)
                .ToList();

        var workItemProducer =
            _workItemProducerFactory.CreateProducer<SubscriptionTriggerWorkItem>();
        foreach (var subscription in enabledSubscriptionsWithTargetFrequency)
        {
            // Get channel and build data from SQL context since these remain in SQL Server
            var channel = await _context.Channels
                .Where(c => c.Id == subscription.ChannelId)
                .Include(c => c.BuildChannels)
                .ThenInclude(bc => bc.Build)
                .FirstOrDefaultAsync();

            if (channel == null)
            {
                _logger.LogWarning("Channel {channelId} for subscription {subscriptionId} was not found in the BAR. Not triggering updates", 
                    subscription.ChannelId, subscription.Id.ToString());
                continue;
            }

            Build? latestBuildInTargetChannel = channel.BuildChannels.Select(bc => bc.Build)
                .Where(b => (subscription.SourceRepository == b.GitHubRepository || subscription.SourceRepository == b.AzureDevOpsRepository))
                .OrderByDescending(b => b.DateProduced)
                .FirstOrDefault();

            bool isThereAnUnappliedBuildInTargetChannel = latestBuildInTargetChannel != null &&
                (subscription.LastAppliedBuild == null || subscription.LastAppliedBuildId != latestBuildInTargetChannel.Id);

            if (isThereAnUnappliedBuildInTargetChannel && latestBuildInTargetChannel != null)
            {
                subscriptionsToTrigger.Add((
                    subscription.SourceEnabled,
                    new SubscriptionTriggerWorkItem
                    {
                        BuildId = latestBuildInTargetChannel.Id,
                        SubscriptionId = subscription.Id,
                    }));
            }
        }

        return subscriptionsToTrigger;
    }
}
