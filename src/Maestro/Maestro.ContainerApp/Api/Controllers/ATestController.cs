// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp.Api.Models;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Queues.WorkItems;
using Maestro.ContainerApp.Utils;
using Maestro.Data;
using Microsoft.AspNetCore.ApiVersioning;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Maestro.ContainerApp.Api.Controllers;

/// <summary>
///   Exposes methods to Create/Read/Update/Delete <see cref="Subscription"/>s
/// </summary>
[Route("api/a-controller")]
[ApiVersion("Latest")]
public class AAA_TestController : Controller
{
    private BuildAssetRegistryContext DBContext { get; }
    private QueueProducerFactory Queue { get; }

    public AAA_TestController(
        BuildAssetRegistryContext context,
        QueueProducerFactory queue)
    {
        DBContext = context;
        Queue = queue;
    }

    [HttpPost("/test-trigger")]
    [ValidateModelState]
    public async Task<IActionResult> TriggerTestSubscription()
    {
        var id = Guid.Parse("0bf57238-1f9d-430b-23b8-08dbb4fecd36");
        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Include(sub => sub.LastAppliedBuild)
            .Include(sub => sub.Channel)
            .FirstOrDefaultAsync(sub => sub.Id == id);

        if (subscription == null)
        {
            return NotFound();
        }

        var client = Queue.Create<StartSubscriptionUpdateWorkItem>();
        await client.SendAsync(new StartSubscriptionUpdateWorkItem
        {
            SubscriptionId = id,
            BuildId = 0,
        });

        return Accepted(new Subscription(subscription));
    }
}
