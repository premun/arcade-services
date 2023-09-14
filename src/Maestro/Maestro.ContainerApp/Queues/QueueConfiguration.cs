// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Queues.QueueProcessors;
using Maestro.ContainerApp.Utils;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Maestro.ContainerApp.Queues;

internal static class QueueConfiguration
{
    public static void AddBackgroudQueueProcessors(this WebApplicationBuilder builder)
    {
        builder.Services.AddTransient<BuildCoherencyInfoQueueProcessor>();
        builder.Services.AddTransient<StartSubscriptionUpdateQueueProcessor>();
        builder.Services.AddTransient<PullRequestReminderQueueProcessor>();

        builder.Services.AddAzureClients(clientBuilder =>
        {
            clientBuilder.AddQueueServiceClient(builder.GetConnectionString("AzureQueues"));
            clientBuilder.ConfigureDefaults(options =>
            {
                options.Diagnostics.IsLoggingEnabled = false;
            });
        });

        var backgroundQueueName = builder.Configuration["BackgroundQueueName"]
            ?? throw new ArgumentException("Please configure the BackgroundQueueName setting");

        builder.Services.AddHostedService(sp
            => ActivatorUtilities.CreateInstance<BackgroundQueueListener>(sp, backgroundQueueName));
        builder.Services.TryAddTransient(sp
            => ActivatorUtilities.CreateInstance<QueueProducerFactory>(sp, backgroundQueueName));
    }
}
