// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Text.Json;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Queues.QueueProcessors;
using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.Contracts;

namespace Maestro.ContainerApp.Queues;

internal class BackgroundQueueListener : BackgroundService
{
    private readonly QueueServiceClient _queueClient;
    private readonly IServiceProvider _serviceProvider;
    private readonly string _queueName;
    private readonly ILogger _logger;

    public BackgroundQueueListener(
        QueueServiceClient queueClient,
        IServiceProvider serviceProvider,
        ILogger<BackgroundQueueListener> logger,
        string queueName)
    {
        _queueClient = queueClient;
        _serviceProvider = serviceProvider;
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        await _queueClient.CreateQueueAsync(_queueName, cancellationToken: cancellationToken);
        QueueClient client = _queueClient.GetQueueClient(_queueName);

        _logger.LogInformation($"Starting queue consumer for queue '{_queueName}'..");

        while (!cancellationToken.IsCancellationRequested)
        {
            QueueMessage message = (await client.ReceiveMessageAsync(cancellationToken: cancellationToken)).Value;

            if (message == null)
            {
                await Task.Delay(1000, cancellationToken);
                continue;
            }

            if (message.DequeueCount > 5)
            {
                _logger.LogError($"Message {message.MessageId} has been dequeued too many times, deleting it");
                await client.DeleteMessageAsync(message.MessageId, message.PopReceipt, cancellationToken);
                continue;
            }

            try
            {
                BackgroundWorkItem item = JsonSerializer.Deserialize<BackgroundWorkItem>(message.Body)
                    ?? throw new InvalidOperationException("Empty message queue received");
                await ProcessItemAsync(item, cancellationToken);
                await client.DeleteMessageAsync(message.MessageId, message.PopReceipt, cancellationToken);
            }
            catch (Exception e)
            {
                _logger.LogError($"Error processing queue item: {e}");
            }
        }
    }

    private async Task ProcessItemAsync(BackgroundWorkItem item, CancellationToken cancellationToken)
    {
        using IServiceScope scope = _serviceProvider.CreateScope();

        switch (item)
        {
            case PullRequestReminderWorkItem checkWorkItem:
                _logger.LogInformation($"Processing {nameof(PullRequestReminderWorkItem)}");
                break;
            case StartSubscriptionUpdateWorkItem startSubscriptionUpdate:
                {
                    var processor = scope.ServiceProvider.GetRequiredService<StartSubscriptionUpdateQueueProcessor>();
                    await processor.ProcessAsync(startSubscriptionUpdate, cancellationToken);
                    break;
                }

            case SubscriptionActorActionWorkItem action:
                _logger.LogInformation($"Processing { nameof(SubscriptionActorActionWorkItem) }: { action.Subscriptionid }, { action.Method }, { action.MethodArguments }");
                break;

            case CheckDailySubscriptionsWorkItem dailyCheck:
                {
                    var processor = scope.ServiceProvider.GetRequiredService<CheckDailySubscriptionsQueueProcessor>();
                    await processor.ProcessAsync(dailyCheck, cancellationToken);
                    break;
                }

            case BuildCoherencyInfoWorkItem action:
                {
                    var processor = scope.ServiceProvider.GetRequiredService<BuildCoherencyInfoQueueProcessor>();
                    await processor.ProcessAsync(action, cancellationToken);
                    break;
                }

            default:
                throw new NotImplementedException($"Unknown work item type: {item.GetType().Name}");
        }
    }
}
