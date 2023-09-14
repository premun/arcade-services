// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.ComponentModel.DataAnnotations;
using System.Net;
using Maestro.Data;
using Maestro.ContainerApp.Utils;
using Maestro.ContainerApp.Api.Models;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Queues.WorkItems;
using Microsoft.AspNetCore.ApiVersioning;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.DotNet.GitHub.Authentication;

namespace Maestro.ContainerApp.Api.Controllers;

/// <summary>
///   Exposes methods to Create/Read/Update/Delete <see cref="Subscription"/>s
/// </summary>
[Route("subscriptions")]
[ApiVersion("Latest")]
public class SubscriptionsController : Controller
{
    public const string RequiredOrgForSubscriptionNotification = "microsoft";

    private BuildAssetRegistryContext DBContext { get; }
    private QueueProducerFactory Queue { get; }
    private IGitHubClientFactory GitHubClientFactory { get; }

    public SubscriptionsController(
        BuildAssetRegistryContext context,
        QueueProducerFactory queue,
        IGitHubClientFactory gitHubClientFactory)
    {
        DBContext = context;
        Queue = queue;
        GitHubClientFactory = gitHubClientFactory;
    }

    /// <summary>
    ///   Gets a list of all <see cref="Subscription"/>s that match the given search criteria.
    /// </summary>
    /// <param name="sourceRepository"></param>
    /// <param name="targetRepository"></param>
    /// <param name="channelId"></param>
    /// <param name="enabled"></param>
    [HttpGet]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(List<Subscription>), Description = "The list of Subscriptions")]
    [ValidateModelState]
    public IActionResult ListSubscriptions(
        string? sourceRepository = null,
        string? targetRepository = null,
        int? channelId = null,
        bool? enabled = null)
    {
        IQueryable<Data.Models.Subscription> query = DBContext.Subscriptions
            .Include(s => s.Channel)
            .Include(s => s.LastAppliedBuild);

        if (!string.IsNullOrEmpty(sourceRepository))
        {
            query = query.Where(sub => sub.SourceRepository == sourceRepository);
        }

        if (!string.IsNullOrEmpty(targetRepository))
        {
            query = query.Where(sub => sub.TargetRepository == targetRepository);
        }

        if (channelId.HasValue)
        {
            query = query.Where(sub => sub.ChannelId == channelId.Value);
        }

        if (enabled.HasValue)
        {
            query = query.Where(sub => sub.Enabled == enabled.Value);
        }

        List<Subscription> results = query.AsEnumerable().Select(sub => new Subscription(sub)).ToList();
        return Ok(results);
    }

    /// <summary>
    ///   Gets a single <see cref="Subscription"/>
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/></param>
    [HttpGet("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Subscription), Description = "The requested Subscription")]
    [ValidateModelState]
    public async Task<IActionResult> GetSubscription(Guid id)
    {
        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Include(sub => sub.LastAppliedBuild)
            .Include(sub => sub.Channel)
            .Include(sub => sub.LastAppliedBuild)
            .FirstOrDefaultAsync(sub => sub.Id == id);

        if (subscription == null)
        {
            return NotFound();
        }

        return Ok(new Subscription(subscription));
    }

    /// <summary>
    ///   Trigger a <see cref="Subscription"/> manually by id
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/> to trigger.</param>
    /// <param name="buildId">'bar-build-id' if specified, a specific build is requested</param>
    [HttpPost("{id}/trigger")]
    //[SwaggerApiResponse(HttpStatusCode.Accepted, Type = typeof(Subscription), Description = "Subscription update has been triggered")]
    [ValidateModelState]
    public async Task<IActionResult> TriggerSubscription(Guid id, [FromQuery(Name = "bar-build-id")] int buildId = 0)
    {
        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Include(sub => sub.LastAppliedBuild)
            .Include(sub => sub.Channel)
            .FirstOrDefaultAsync(sub => sub.Id == id);

        if (subscription == null)
        {
            return NotFound();
        }

        if (buildId != 0)
        {
            Data.Models.Build? build = await DBContext.Builds.Where(b => b.Id == buildId).FirstOrDefaultAsync();
            // Non-existent build
            if (build == null)
            {
                return BadRequest($"Build {buildId} was not found");
            }
            // Build doesn't match source repo
            if (!(build.GitHubRepository?.Equals(subscription.SourceRepository, StringComparison.InvariantCultureIgnoreCase) == true ||
                  build.AzureDevOpsRepository?.Equals(subscription.SourceRepository, StringComparison.InvariantCultureIgnoreCase) == true))
            {
                return BadRequest($"Build {buildId} does not match source repo");
            }
        }

        var client = Queue.Create<StartSubscriptionUpdateWorkItem>();
        await client.SendAsync(new StartSubscriptionUpdateWorkItem
        {
            SubscriptionId = id,
            BuildId = buildId,
        });
        return Accepted(new Subscription(subscription));
    }

    [HttpPost("/test-trigger")]
    [ValidateModelState]
    public async Task<IActionResult> TriggerTestSubscription()
    {
        return await TriggerSubscription(new Guid("0bf57238-1f9d-430b-23b8-08dbb4fecd36"), 0);
    }

    /// <summary>
    ///   Trigger daily update
    /// </summary>
    [HttpPost("triggerDaily")]
    //[SwaggerApiResponse(HttpStatusCode.Accepted, Description = "Trigger all subscriptions normally updated daily.")]
    [ValidateModelState]
    public async Task<IActionResult> TriggerDailyUpdate()
    {
        var client = Queue.Create<CheckDailySubscriptionsWorkItem>();
        await client.SendAsync(new CheckDailySubscriptionsWorkItem());

        return Accepted();
    }

    /// <summary>
    ///   Edit an existing <see cref="Subscription"/>
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/> to update</param>
    /// <param name="update">An object containing the new data for the <see cref="Subscription"/></param>
    [HttpPatch("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Subscription), Description = "Subscription successfully updated")]
    [ValidateModelState]
    public async Task<IActionResult> UpdateSubscription(Guid id, [FromBody] SubscriptionUpdate update)
    {
        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Where(sub => sub.Id == id).Include(sub => sub.Channel)
            .FirstOrDefaultAsync();

        if (subscription == null)
        {
            return NotFound();
        }

        var doUpdate = false;

        if (!string.IsNullOrEmpty(update.SourceRepository))
        {
            subscription.SourceRepository = update.SourceRepository;
            doUpdate = true;
        }

        if (update.Policy != null)
        {
            subscription.PolicyObject = update.Policy.ToDb();
            doUpdate = true;
        }

        if (update.PullRequestFailureNotificationTags != null)
        {
            if (!await AllNotificationTagsValid(update.PullRequestFailureNotificationTags))
            {
                return BadRequest(new ApiError("Invalid value(s) provided in Pull Request Failure Notification Tags; is everyone listed publicly a member of the Microsoft github org?"));
            }

            subscription.PullRequestFailureNotificationTags = update.PullRequestFailureNotificationTags;
            doUpdate = true;
        }

        if (!string.IsNullOrEmpty(update.ChannelName))
        {
            Data.Models.Channel? channel = await DBContext.Channels.Where(c => c.Name == update.ChannelName)
                .FirstOrDefaultAsync();
            if (channel == null)
            {
                return BadRequest(
                    new ApiError(
                        "The request is invalid",
                        new[] { $"The channel '{update.ChannelName}' could not be found." }));
            }

            subscription.Channel = channel;
            doUpdate = true;
        }

        if (update.Enabled.HasValue)
        {
            subscription.Enabled = update.Enabled.Value;
            doUpdate = true;
        }

        if (doUpdate)
        {
            Data.Models.Subscription? equivalentSubscription = await FindEquivalentSubscription(subscription);
            if (equivalentSubscription != null)
            {
                return Conflict(
                    new ApiError(
                        "the request is invalid",
                        new[]
                        {
                            $"The subscription '{equivalentSubscription.Id}' already performs the same update."
                        }));
            }

            DBContext.Subscriptions.Update(subscription);
            await DBContext.SaveChangesAsync();
        }


        return Ok(new Subscription(subscription));
    }

    /// <summary>
    ///   Delete an existing <see cref="Subscription"/>
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/> to delete</param>
    [HttpDelete("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Subscription), Description = "Subscription successfully deleted")]
    [ValidateModelState]
    public async Task<IActionResult> DeleteSubscription(Guid id)
    {
        Data.Models.Subscription? subscription =
            await DBContext.Subscriptions.FirstOrDefaultAsync(sub => sub.Id == id);

        if (subscription == null)
        {
            return NotFound();
        }

        Data.Models.SubscriptionUpdate? subscriptionUpdate =
            await DBContext.SubscriptionUpdates.FirstOrDefaultAsync(u => u.SubscriptionId == subscription.Id);

        if (subscriptionUpdate != null)
        {
            DBContext.SubscriptionUpdates.Remove(subscriptionUpdate);
        }

        DBContext.Subscriptions.Remove(subscription);

        await DBContext.SaveChangesAsync();
        return Ok(new Subscription(subscription));
    }

    /// <summary>
    ///   Gets a paginated list of the Subscription history for the given Subscription
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/> to get history for</param>
    [HttpGet("{id}/history")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(List<SubscriptionHistoryItem>), Description = "The list of Subscription history")]
    //[Paginated(typeof(SubscriptionHistoryItem))]
    public virtual async Task<IActionResult> GetSubscriptionHistory(Guid id)
    {
        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Where(sub => sub.Id == id)
            .FirstOrDefaultAsync();

        if (subscription == null)
        {
            return NotFound();
        }

        IOrderedQueryable<SubscriptionUpdateHistoryEntry> query = DBContext.SubscriptionUpdateHistory
            .Where(u => u.SubscriptionId == id)
            .OrderByDescending(u => u.Timestamp);

        return Ok(query);
    }

    /// <summary>
    ///   Requests that Maestro++ retry the reference history item.
    ///   Links to this api are returned from the <see cref="GetSubscriptionHistory"/> api.
    /// </summary>
    /// <param name="id">The id of the <see cref="Subscription"/> containing the history item to retry</param>
    /// <param name="timestamp">The timestamp identifying the history item to retry</param>
    [HttpPost("{id}/retry/{timestamp}")]
    //[SwaggerApiResponse(HttpStatusCode.Accepted, Description = "Retry successfully requested")]
    //[SwaggerApiResponse(HttpStatusCode.NotAcceptable, Description = "The requested history item was successful and cannot be retried")]
    public virtual async Task<IActionResult> RetrySubscriptionActionAsync(Guid id, long timestamp)
    {
        DateTime ts = DateTimeOffset.FromUnixTimeSeconds(timestamp).UtcDateTime;

        Data.Models.Subscription? subscription = await DBContext.Subscriptions.Where(sub => sub.Id == id)
            .FirstOrDefaultAsync();

        if (subscription == null)
        {
            return NotFound();
        }

        SubscriptionUpdateHistoryEntry? update = await DBContext.SubscriptionUpdateHistory
            .Where(u => u.SubscriptionId == id)
            .FirstOrDefaultAsync(u => Math.Abs(EF.Functions.DateDiffSecond(u.Timestamp, ts)) < 1);

        if (update == null)
        {
            return NotFound();
        }

        if (update.Success)
        {
            return StatusCode(
                (int)HttpStatusCode.NotAcceptable,
                new ApiError("That action was successful, it cannot be retried."));
        }

        var client = Queue.Create<SubscriptionActorActionWorkItem>();
        await client.SendAsync(new SubscriptionActorActionWorkItem
        {
            Subscriptionid = subscription.Id,
            Method = update.Method,
            MethodArguments = update.Arguments
        });

        return Accepted();
    }

    /// <summary>
    ///   Creates a new <see cref="Subscription"/>
    /// </summary>
    /// <param name="subscription">An object containing data for the new <see cref="Subscription"/></param>
    [HttpPost]
    //[SwaggerApiResponse(HttpStatusCode.Created, Type = typeof(Subscription), Description = "New Subscription successfully created")]
    [ValidateModelState]
    public async Task<IActionResult> Create([FromBody, Required] SubscriptionData subscription)
    {
        Data.Models.Channel? channel = await DBContext.Channels.Where(c => c.Name == subscription.ChannelName)
            .FirstOrDefaultAsync();
        if (channel == null)
        {
            return BadRequest(
                new ApiError(
                    "the request is invalid",
                    new[] { $"The channel '{subscription.ChannelName}' could not be found." }));
        }

        Data.Models.Repository? repo = await DBContext.Repositories.FindAsync(subscription.TargetRepository);

        if (subscription.TargetRepository is not null && subscription.TargetRepository.Contains("github.com"))
        {
            // If we have no repository information or an invalid installation id
            // then we will fail when trying to update things, so we fail early.
            if (repo == null || repo.InstallationId <= 0)
            {
                return BadRequest(
                    new ApiError(
                        "the request is invalid",
                        new[]
                        {
                            $"The repository '{subscription.TargetRepository}' does not have an associated github installation. " +
                            "The Maestro github application must be installed by the repository's owner and given access to the repository."
                        }));
            }
        }
        // In the case of a dev.azure.com repository, we don't have an app installation,
        // but we should add an entry in the repositories table, as this is required when
        // adding a new subscription policy.
        // NOTE:
        // There is a good chance here that we will need to also handle <account>.visualstudio.com
        // but leaving it out for now as it would be preferred to use the new format
        else if (subscription.TargetRepository is not null && subscription.TargetRepository.Contains("dev.azure.com"))
        {
            if (repo == null)
            {
                DBContext.Repositories.Add(
                    new Data.Models.Repository
                    {
                        RepositoryName = subscription.TargetRepository,
                        InstallationId = default
                    });
            }
        }

        Data.Models.Subscription subscriptionModel = subscription.ToDb();
        subscriptionModel.Channel = channel;

        // Check that we're not about add an existing subscription that is identical
        Data.Models.Subscription? equivalentSubscription = await FindEquivalentSubscription(subscriptionModel);
        if (equivalentSubscription != null)
        {
            return BadRequest(
                new ApiError(
                    "the request is invalid",
                    new[]
                    {
                        $"The subscription '{equivalentSubscription.Id}' already performs the same update."
                    }));
        }

        if (!string.IsNullOrEmpty(subscriptionModel.PullRequestFailureNotificationTags))
        {
            if (!await AllNotificationTagsValid(subscriptionModel.PullRequestFailureNotificationTags))
            {
                return BadRequest(new ApiError("Invalid value(s) provided in Pull Request Failure Notification Tags; is everyone listed publicly a member of the Microsoft github org?"));
            }
        }

        await DBContext.Subscriptions.AddAsync(subscriptionModel);
        await DBContext.SaveChangesAsync();
        return CreatedAtRoute(
            new
            {
                action = "GetSubscription",
                id = subscriptionModel.Id
            },
            new Subscription(subscriptionModel));
    }

    /// <summary>
    ///     Find an existing subscription in the database with the same key data as the subscription we are adding/updating
    ///     
    ///     This should be called before updating or adding new subscriptions to the database
    /// </summary>
    /// <param name="updatedOrNewSubscription">Subscription model with updated data.</param>
    /// <returns>Subscription if it is found, null otherwise</returns>
    private async Task<Data.Models.Subscription?> FindEquivalentSubscription(Data.Models.Subscription updatedOrNewSubscription)
    {
        // Compare subscriptions based on the 4 key elements:
        // - Channel
        // - Source repo
        // - Target repo
        // - Target branch
        // - Not the same subscription id (for updates)
        return await DBContext.Subscriptions.FirstOrDefaultAsync(sub =>
            sub.SourceRepository == updatedOrNewSubscription.SourceRepository &&
            sub.ChannelId == updatedOrNewSubscription.Channel.Id &&
            sub.TargetRepository == updatedOrNewSubscription.TargetRepository &&
            sub.TargetBranch == updatedOrNewSubscription.TargetBranch &&
            sub.Id != updatedOrNewSubscription.Id);
    }

    /// <summary>
    ///  Subscriptions support notifying GitHub tags when non-batched dependency flow PRs fail checks.
    ///  Before inserting them into the database, we'll make sure they're either not a user's login or
    ///  that user is publicly a member of the Microsoft organization so we can store their login.
    /// </summary>
    /// <param name="pullRequestFailureNotificationTags"></param>
    /// <returns></returns>
    private async Task<bool> AllNotificationTagsValid(string pullRequestFailureNotificationTags)
    {
        string[] allTags = pullRequestFailureNotificationTags.Split(';', StringSplitOptions.RemoveEmptyEntries);

        // We'll only be checking public membership in the Microsoft org, so no token needed
        var client = GitHubClientFactory.CreateGitHubClient(string.Empty);
        bool success = true;

        foreach (string tagToNotify in allTags)
        {
            // remove @ if it's there
            string tag = tagToNotify.TrimStart('@');

            try
            {
                IReadOnlyList<Octokit.Organization> orgList = await client.Organization.GetAllForUser(tag);
                success &= orgList.Any(o => o.Login?.Equals(RequiredOrgForSubscriptionNotification, StringComparison.InvariantCultureIgnoreCase) == true);
            }
            catch (Octokit.NotFoundException)
            {
                // Non-existent user: Either a typo, or a group (we don't have the admin privilege to find out, so just allow it)
            }
        }

        return success;
    }
}
