// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Maestro.Data.Models;
using Maestro.Data.Models.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Maestro.Data.Services;

/// <summary>
/// SQLite-based implementation of subscription service
/// Provides ephemeral subscription storage during service runtime
/// Uses SQL Server for subscription update history
/// </summary>
public class SqliteSubscriptionService : ISubscriptionService
{
    private readonly SqliteSubscriptionContext _context;
    private readonly BuildAssetRegistryContext _sqlContext;
    private readonly ILogger<SqliteSubscriptionService> _logger;

    public SqliteSubscriptionService(
        SqliteSubscriptionContext context, 
        BuildAssetRegistryContext sqlContext,
        ILogger<SqliteSubscriptionService> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _sqlContext = sqlContext ?? throw new ArgumentNullException(nameof(sqlContext));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<IEnumerable<Subscription>> GetSubscriptionsAsync(
        string sourceRepo = null, 
        string targetRepo = null, 
        int? channelId = null,
        bool? sourceEnabled = null,
        string sourceDirectory = null,
        string targetDirectory = null)
    {
        var query = _context.Subscriptions.AsQueryable();

        if (!string.IsNullOrEmpty(sourceRepo))
        {
            query = query.Where(s => s.SourceRepository == sourceRepo);
        }

        if (!string.IsNullOrEmpty(targetRepo))
        {
            query = query.Where(s => s.TargetRepository == targetRepo);
        }

        if (channelId.HasValue)
        {
            query = query.Where(s => s.ChannelId == channelId.Value);
        }

        if (sourceEnabled.HasValue)
        {
            query = query.Where(s => s.SourceEnabled == sourceEnabled.Value);
        }

        if (!string.IsNullOrEmpty(sourceDirectory))
        {
            query = query.Where(s => s.SourceDirectory == sourceDirectory);
        }

        if (!string.IsNullOrEmpty(targetDirectory))
        {
            query = query.Where(s => s.TargetDirectory == targetDirectory);
        }

        var sqliteSubscriptions = await query.ToListAsync();
        return sqliteSubscriptions.Select(s => s.ToSqlSubscription());
    }

    public async Task<Subscription> GetSubscriptionAsync(Guid subscriptionId)
    {
        var sqliteSubscription = await _context.Subscriptions
            .FirstOrDefaultAsync(s => s.Id == subscriptionId);

        return sqliteSubscription?.ToSqlSubscription();
    }

    public async Task<Subscription> CreateSubscriptionAsync(Subscription subscription)
    {
        if (subscription.Id == Guid.Empty)
        {
            subscription.Id = Guid.NewGuid();
        }

        var sqliteSubscription = SqliteSubscription.FromSqlSubscription(subscription);
        
        _context.Subscriptions.Add(sqliteSubscription);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Created subscription {SubscriptionId} from {SourceRepo} to {TargetRepo}",
            subscription.Id, subscription.SourceRepository, subscription.TargetRepository);

        return sqliteSubscription.ToSqlSubscription();
    }

    public async Task<Subscription> UpdateSubscriptionAsync(Subscription subscription)
    {
        var existingSqliteSubscription = await _context.Subscriptions
            .FirstOrDefaultAsync(s => s.Id == subscription.Id);

        if (existingSqliteSubscription == null)
        {
            throw new InvalidOperationException($"Subscription {subscription.Id} not found");
        }

        // Update properties
        existingSqliteSubscription.ChannelId = subscription.ChannelId;
        existingSqliteSubscription.SourceRepository = subscription.SourceRepository;
        existingSqliteSubscription.TargetRepository = subscription.TargetRepository;
        existingSqliteSubscription.TargetBranch = subscription.TargetBranch;
        existingSqliteSubscription.PolicyString = subscription.PolicyString;
        existingSqliteSubscription.Enabled = subscription.Enabled;
        existingSqliteSubscription.SourceEnabled = subscription.SourceEnabled;
        existingSqliteSubscription.SourceDirectory = subscription.SourceDirectory;
        existingSqliteSubscription.TargetDirectory = subscription.TargetDirectory;
        existingSqliteSubscription.ExcludedAssets = subscription.ExcludedAssets?.Select(a => a.Filter).ToList() ?? [];
        existingSqliteSubscription.LastAppliedBuildId = subscription.LastAppliedBuildId;
        existingSqliteSubscription.PullRequestFailureNotificationTags = subscription.PullRequestFailureNotificationTags;
        existingSqliteSubscription.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Updated subscription {SubscriptionId}", subscription.Id);

        return existingSqliteSubscription.ToSqlSubscription();
    }

    public async Task<bool> DeleteSubscriptionAsync(Guid subscriptionId)
    {
        var subscription = await _context.Subscriptions
            .FirstOrDefaultAsync(s => s.Id == subscriptionId);

        if (subscription == null)
        {
            return false;
        }

        // Remove subscription update history from SQL Server
        var historyEntries = await _sqlContext.SubscriptionUpdateHistory
            .Where(h => h.SubscriptionId == subscriptionId)
            .ToListAsync();

        _sqlContext.SubscriptionUpdateHistory.RemoveRange(historyEntries);
        await _sqlContext.SaveChangesAsync();

        // Remove subscription from SQLite
        _context.Subscriptions.Remove(subscription);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Deleted subscription {SubscriptionId} and {HistoryCount} history entries", 
            subscriptionId, historyEntries.Count);

        return true;
    }

    public async Task<SubscriptionUpdate> GetSubscriptionUpdateAsync(Guid subscriptionId)
    {
        // Get the latest subscription update history entry from SQL Server
        var historyEntry = await _sqlContext.SubscriptionUpdateHistory
            .Where(h => h.SubscriptionId == subscriptionId)
            .OrderByDescending(h => h.Timestamp)
            .FirstOrDefaultAsync();

        if (historyEntry == null)
            return null;

        // Convert from history to update model
        return new SubscriptionUpdate
        {
            SubscriptionId = historyEntry.SubscriptionId,
            Success = historyEntry.Success,
            Action = historyEntry.Action,
            ErrorMessage = historyEntry.ErrorMessage,
            Method = historyEntry.Method,
            Arguments = historyEntry.Arguments
        };
    }

    public async Task UpdateSubscriptionUpdateAsync(SubscriptionUpdate subscriptionUpdate)
    {
        // Add to subscription update history in SQL Server
        var historyEntry = new SubscriptionUpdateHistory
        {
            SubscriptionId = subscriptionUpdate.SubscriptionId,
            Success = subscriptionUpdate.Success,
            Action = subscriptionUpdate.Action,
            ErrorMessage = subscriptionUpdate.ErrorMessage,
            Method = subscriptionUpdate.Method,
            Arguments = subscriptionUpdate.Arguments,
            Timestamp = DateTime.UtcNow
        };

        _sqlContext.SubscriptionUpdateHistory.Add(historyEntry);
        await _sqlContext.SaveChangesAsync();

        _logger.LogDebug("Added subscription update history for {SubscriptionId}", subscriptionUpdate.SubscriptionId);
    }

    public async Task<IEnumerable<SubscriptionUpdate>> GetSubscriptionUpdateHistoryAsync(
        Guid? subscriptionId = null,
        int skip = 0,
        int take = 100)
    {
        var query = _sqlContext.SubscriptionUpdateHistory.AsQueryable();

        if (subscriptionId.HasValue)
        {
            query = query.Where(h => h.SubscriptionId == subscriptionId.Value);
        }

        var historyEntries = await query
            .OrderByDescending(h => h.Timestamp)
            .Skip(skip)
            .Take(take)
            .ToListAsync();

        // Convert from history to update model
        return historyEntries.Select(h => new SubscriptionUpdate
        {
            SubscriptionId = h.SubscriptionId,
            Success = h.Success,
            Action = h.Action,
            ErrorMessage = h.ErrorMessage,
            Method = h.Method,
            Arguments = h.Arguments
        });
    }

    public async Task<bool> SubscriptionExistsAsync(Guid subscriptionId)
    {
        return await _context.Subscriptions
            .AnyAsync(s => s.Id == subscriptionId);
    }

    public async Task<IEnumerable<Subscription>> GetSubscriptionsByChannelAsync(int channelId)
    {
        var sqliteSubscriptions = await _context.Subscriptions
            .Where(s => s.ChannelId == channelId)
            .ToListAsync();

        return sqliteSubscriptions.Select(s => s.ToSqlSubscription());
    }

    public async Task<IEnumerable<Subscription>> GetEnabledSubscriptionsAsync()
    {
        var sqliteSubscriptions = await _context.Subscriptions
            .Where(s => s.Enabled)
            .ToListAsync();

        return sqliteSubscriptions.Select(s => s.ToSqlSubscription());
    }

    public async Task UpdateSubscriptionsAsync(IEnumerable<Subscription> subscriptions)
    {
        foreach (var subscription in subscriptions)
        {
            await UpdateSubscriptionAsync(subscription);
        }

        _logger.LogInformation("Bulk updated {Count} subscriptions", subscriptions.Count());
    }
}