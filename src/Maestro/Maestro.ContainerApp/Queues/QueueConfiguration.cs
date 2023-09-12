// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Maestro.ContainerApp.Queues;

internal static class QueueConfiguration
{
    public const string SubscriptionTriggerQueueName = "subscriptions";

    public static void AddAzureQueues(this IServiceCollection services)
    {
        services.AddAzureClients(clientBuilder =>
        {
            // TODO: This would get replaced with a connection string from builder.Configuration["StorageConnectionString:queue"]
            clientBuilder.AddQueueServiceClient("UseDevelopmentStorage=true;DevelopmentStorageProxyUri=http://host.docker.internal");
            clientBuilder.ConfigureDefaults(options =>
            {
                options.Diagnostics.IsLoggingEnabled = false;
            });
        });

        services.TryAddTransient<QueueProducerFactory>();
    }
}
