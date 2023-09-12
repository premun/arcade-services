// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Maestro.ContainerApp.Queues;

internal static class QueueConfiguration
{
    public const string SubscriptionTriggerQueueName = "subscriptions";

    public static void AddAzureQueues(this WebApplicationBuilder builder)
    {
        builder.Services.AddAzureClients(clientBuilder =>
        {
            clientBuilder.AddQueueServiceClient(builder.Configuration.GetSection("ConnectionStrings")["AzureQueues"]);
            clientBuilder.ConfigureDefaults(options =>
            {
                options.Diagnostics.IsLoggingEnabled = false;
            });
        });

        builder.Services.TryAddTransient<QueueProducerFactory>();
    }
}
