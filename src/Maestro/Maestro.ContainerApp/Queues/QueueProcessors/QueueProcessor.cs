// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Queues.WorkItems;

namespace Maestro.ContainerApp.Queues.QueueProcessors;

internal abstract class QueueProcessor<T> where T : BackgroundWorkItem
{
    private readonly ILogger _logger;

    public QueueProcessor(ILogger logger)
    {
        _logger = logger;
    }

    public async Task ProcessAsync(T workItem, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Processing {Type} {WorkItemId}", typeof(T).Name, workItem.WorkItemId);
        await ProcessAsyncInternal(workItem, cancellationToken);
        _logger.LogInformation("Finished processing {Type} {WorkItemId}", typeof(T).Name, workItem.WorkItemId);
    }

    protected abstract Task ProcessAsyncInternal(T workItem, CancellationToken cancellationToken);
}
