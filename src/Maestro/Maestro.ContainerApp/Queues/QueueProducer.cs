// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text.Json;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Maestro.ContainerApp.Queues.WorkItems;

namespace Maestro.ContainerApp.Queues;

public class QueueProducer<T> where T : BackgroundWorkItem
{
    private readonly QueueServiceClient _queueClient;
    private readonly string _queueName;

    public QueueProducer(QueueServiceClient queueClient, string queueName)
    {
        _queueClient = queueClient;
        _queueName = queueName;
    }

    public async Task SendAsync(T message)
    {
        var client = _queueClient.GetQueueClient(_queueName);
        var json = JsonSerializer.Serialize<BackgroundWorkItem>(message);
        await client.SendMessageAsync(json);
    }

    public async Task<SendReceipt> SendAsync(T message, TimeSpan? visibilityTimeout)
    {
        var client = _queueClient.GetQueueClient(_queueName);
        var json = JsonSerializer.Serialize<BackgroundWorkItem>(message);
        return await client.SendMessageAsync(json, visibilityTimeout: visibilityTimeout);
    }

    public async Task DeleteAsync(string messageId, string popReceipt)
    {
        var client = _queueClient.GetQueueClient(_queueName);
        await client.DeleteMessageAsync(messageId, popReceipt);
    }
}
