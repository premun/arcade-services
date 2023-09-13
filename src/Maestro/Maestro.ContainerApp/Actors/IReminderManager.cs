﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text.Json;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Queues.WorkItems;
using StackExchange.Redis;

/// TODO: remove & fix issues
#nullable disable
namespace Maestro.ContainerApp.Actors;

public interface IReminderManager
{
    Task TryRegisterReminderAsync(string reminderName, TimeSpan period);

    Task TryUnregisterReminderAsync(string reminderName);
}

public class ReminderManager : IReminderManager
{
    private QueueProducerFactory Queue { get; }
    public IConnectionMultiplexer Redis { get; }
    public IDatabase Database { get; }

    public ReminderManager(QueueProducerFactory queue, IConnectionMultiplexer redis)
    {
        Queue = queue;
        Redis = redis;
        Database = redis.GetDatabase();
    }

    public async Task TryRegisterReminderAsync(string reminderName, TimeSpan period)
    {
        var client = Queue.Create<PullRequestCheckWorkItem>();
        var sendReceipt = await client.SendAsync(new PullRequestCheckWorkItem(), period);
        await Database.StringSetAsync(reminderName,
            JsonSerializer.Serialize(new ReminderArguments(sendReceipt.PopReceipt, sendReceipt.MessageId)));
    }

    public async Task TryUnregisterReminderAsync(string reminderName)
    {
        var reminderRecord = await Database.StringGetAsync(reminderName);
        if(reminderRecord == RedisValue.Null)
        {
            return;
        }

        var reminderMessage = JsonSerializer.Deserialize<ReminderArguments>(await Database.StringGetAsync(reminderName));
        var client = Queue.Create<PullRequestCheckWorkItem>();
        await client.DeleteAsync(reminderMessage.MessageId, reminderMessage.PopReceipt);
    }

    private class ReminderArguments
    {
        public string PopReceipt { get; set; }

        public string MessageId { get; set; }

        public ReminderArguments(string popReceipt, string messageId)
        {
            PopReceipt = popReceipt;
            MessageId = messageId;
        }
    }
}
