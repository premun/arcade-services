// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text.Json;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Queues.WorkItems;
using StackExchange.Redis;

namespace Maestro.ContainerApp.Actors;

public interface IReminderManager
{
    Task TryRegisterReminderAsync(string reminderName, PullRequestActorId actorId, TimeSpan visibilityTimeout);

    Task TryUnregisterReminderAsync(string reminderName);
}

public class ReminderManager : IReminderManager
{
    private readonly QueueProducerFactory _queue;
    private readonly IConnectionMultiplexer _redis;
    private readonly IDatabase _database;

    public ReminderManager(QueueProducerFactory queue, IConnectionMultiplexer redis)
    {
        _queue = queue;
        _redis = redis;
        _database = _redis.GetDatabase();
    }

    public async Task TryRegisterReminderAsync(string reminderName, PullRequestActorId actorId, TimeSpan visibilityTimeout)
    {
        var client = _queue.Create<PullRequestReminderWorkItem>();
        var sendReceipt = await client.SendAsync(new PullRequestReminderWorkItem(reminderName, actorId), visibilityTimeout);
        await _database.StringSetAsync(reminderName,
            JsonSerializer.Serialize(new ReminderArguments(sendReceipt.PopReceipt, sendReceipt.MessageId)));
    }

    public async Task TryUnregisterReminderAsync(string reminderName)
    {
        var reminderRecord = await _database.StringGetAsync(reminderName);
        if(reminderRecord == RedisValue.Null)
        {
            return;
        }

        var reminderMessage = JsonSerializer.Deserialize<ReminderArguments>(reminderRecord!)
            ?? throw new Exception("Reminder deserialization failed");

        var client = _queue.Create<PullRequestReminderWorkItem>();
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
