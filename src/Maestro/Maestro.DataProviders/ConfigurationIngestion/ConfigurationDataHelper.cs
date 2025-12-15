// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using Maestro.Data.Models;
using Microsoft.DotNet.DarcLib.Models.Yaml;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

#nullable enable
namespace Maestro.DataProviders.ConfigurationIngestion;

internal class ConfigurationDataHelper
{
    internal static ConfigurationDataUpdate ComputeEntityUpdates(
        ConfigurationData configurationData,
        ConfigurationData existingConfigurationData)
    {
        EntityChanges<SubscriptionYaml> subscriptionChanges = ComputeUpdatesForEntity(
            existingConfigurationData.Subscriptions,
            configurationData.Subscriptions,
            IdFactories.Subscription);

        EntityChanges<ChannelYaml> channelChanges = ComputeUpdatesForEntity(
            existingConfigurationData.Channels,
            configurationData.Channels,
            IdFactories.Channel);

        EntityChanges<DefaultChannelYaml> defaultChannelChanges = ComputeUpdatesForEntity(
            existingConfigurationData.DefaultChannels,
            configurationData.DefaultChannels,
            IdFactories.DefaultChannel);

        EntityChanges<BranchMergePoliciesYaml> branchMergePolicyChanges = ComputeUpdatesForEntity(
            existingConfigurationData.BranchMergePolicies,
            configurationData.BranchMergePolicies,
            IdFactories.BranchMergePolicy);

        return new ConfigurationDataUpdate(
            subscriptionChanges,
            channelChanges,
            defaultChannelChanges,
            branchMergePolicyChanges);
    }

    internal static EntityChanges<T> ComputeUpdatesForEntity<T, TId>(
            IEnumerable<T> dbEntities,
            IEnumerable<T> externalEntities,
            Func<T, TId> keySelector)
        where T : class
        where TId : notnull
    {
        var dbEntitiesById = dbEntities.ToDictionary(keySelector);
        var externalEntitiesById = externalEntities.ToDictionary(keySelector);

        IEnumerable<T> creations =
        [
            .. externalEntitiesById.Keys.Except(dbEntitiesById.Keys).Select(k => externalEntitiesById[k])
        ];

        IEnumerable<T> removals =
        [
            .. dbEntitiesById.Keys.Except(externalEntitiesById.Keys).Select(k => dbEntitiesById[k])
        ];

        IEnumerable<T> updates =
        [
            ..externalEntitiesById.Keys.Intersect(dbEntitiesById.Keys).Select(k => externalEntitiesById[k])
        ] ;

        return new EntityChanges<T>(creations, updates, removals);
    }

    internal static Subscription ConvertSubscriptionToDaoYaml(
        SubscriptionYaml subscription,
        Namespace namespaceEntity,
        Dictionary<string, Channel> existingChannelsByName)
    {
        existingChannelsByName.TryGetValue(subscription.Channel, out Channel? existingChannel);

        if (existingChannel is null)
        {
            //todo find the right exception type
            throw new InvalidOperationException(
                $"Channel '{subscription.Channel}' not found for subscription creation.");
        }

        return new Subscription
        {
            Id = subscription.Id,
            ChannelId = existingChannel.Id,
            Channel = existingChannel,
            SourceRepository = subscription.SourceRepository,
            TargetRepository = subscription.TargetRepository,
            TargetBranch = subscription.TargetBranch,
            PolicyObject = new SubscriptionPolicy
            {
                UpdateFrequency = (UpdateFrequency)(int)subscription.UpdateFrequency,
                Batchable = subscription.Batchable,
                MergePolicies = [.. subscription.MergePolicies.Select(ConvertMergePolicyYamlToDao)],
            },
            Enabled = subscription.Enabled,
            SourceEnabled = subscription.SourceEnabled,
            SourceDirectory = subscription.SourceDirectory,
            TargetDirectory = subscription.TargetDirectory,
            PullRequestFailureNotificationTags = subscription.FailureNotificationTags,
            ExcludedAssets = subscription.ExcludedAssets == null ? [] : [.. subscription.ExcludedAssets.Select(asset => new AssetFilter() { Filter = asset })],
            Namespace = namespaceEntity,
        };
    }

    internal static Channel ConvertChannelToDaoYaml(
        ChannelYaml channel,
        Namespace namespaceEntity)
        =>  new()
        {
            Name = channel.Name,
            Classification = channel.Classification,
            Namespace = namespaceEntity,
        };

    internal static DefaultChannel ConvertDefaultChannelToDaoYaml(
        DefaultChannelYaml defaultChannel,
        Namespace namespaceEntity,
        Dictionary<string, Channel> existingChannelsByName,
        Dictionary<(string, string, string), DefaultChannelYaml>? existingDefaultChannels)
    {
        existingChannelsByName.TryGetValue(defaultChannel.Channel, out Channel? existingChannel);

        if (existingChannel is null)
        {
            //todo find the right exception type
            throw new InvalidOperationException(
                $"Channel '{defaultChannel.Channel}' not found for default channel creation.");
        }

        DefaultChannelYaml? existingDefaultChannel = null;

        existingDefaultChannels?.TryGetValue(defaultChannel.UniqueId, out existingDefaultChannel);

        var defaultChannelDao = new DefaultChannel
        {
            ChannelId = existingChannel.Id,
            Channel = existingChannel,
            Repository = defaultChannel.Repository,
            Namespace = namespaceEntity,
            Branch = defaultChannel.Branch,
            Enabled = defaultChannel.Enabled,
        };

        return defaultChannelDao;
    }

    internal static RepositoryBranch ConvertBranchMergePoliciesToDaoYaml(
        BranchMergePoliciesYaml branchMergePolicies,
        Namespace namespaceEntity)
    {
        var policyObject = new RepositoryBranch.Policy
        {
            MergePolicies = [.. branchMergePolicies.MergePolicies.Select(ConvertMergePolicyYamlToDao)],
        };

        var branchMergePolicyDao = new RepositoryBranch
        {
            RepositoryName = branchMergePolicies.Repository,
            BranchName = branchMergePolicies.Branch,
            PolicyString = JsonConvert.SerializeObject(policyObject),
            Namespace = namespaceEntity,
        };

        return branchMergePolicyDao;
    }

    private static MergePolicyDefinition ConvertMergePolicyYamlToDao(MergePolicyYaml mergePolicy)
        => new()
        {
            Name = mergePolicy.Name,
            Properties = mergePolicy.Properties?.ToDictionary(
                p => p.Key,
                p => JToken.FromObject(p.Value)), // todo: this seems fragile. Can we change MergePolicyYaml to be <string, JToken> like the DAO & DTO?
        };
}
