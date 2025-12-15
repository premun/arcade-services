// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using Microsoft.DotNet.DarcLib.Models.Yaml;

namespace Maestro.DataProviders.ConfigurationIngestion;

internal static class IdFactories
{
    public static Guid Subscription(SubscriptionYaml sub) => sub.Id;
    public static string Channel(ChannelYaml channel) => channel.Name;
    public static (string Repository, string Branch, string Channel) DefaultChannel(DefaultChannelYaml defaultChannel)
        => (defaultChannel.Repository, defaultChannel.Branch, defaultChannel.Channel);
    public static (string Repository, string Branch) BranchMergePolicy(BranchMergePoliciesYaml policy)
        => (policy.Repository, policy.Branch);
}
