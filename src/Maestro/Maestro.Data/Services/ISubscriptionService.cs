// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Maestro.Data.Models;

namespace Maestro.Data.Services;

/// <summary>
/// Interface for subscription data access operations
/// Abstracts the underlying storage mechanism (SQL Server, SQLite, etc.)
/// </summary>
public interface ISubscriptionService
{
    /// <summary>
    /// Get all subscriptions with optional filtering
    /// </summary>
    Task<IEnumerable<Subscription>> GetSubscriptionsAsync(
        string sourceRepo = null, 
        string targetRepo = null, 
        int? channelId = null,
        bool? sourceEnabled = null,
        string sourceDirectory = null,
        string targetDirectory = null);

    /// <summary>
    /// Get a subscription by ID
    /// </summary>
    Task<Subscription> GetSubscriptionAsync(Guid subscriptionId);

    /// <summary>
    /// Create a new subscription
    /// </summary>
    Task<Subscription> CreateSubscriptionAsync(Subscription subscription);

    /// <summary>
    /// Update an existing subscription
    /// </summary>
    Task<Subscription> UpdateSubscriptionAsync(Subscription subscription);

    /// <summary>
    /// Delete a subscription
    /// </summary>
    Task<bool> DeleteSubscriptionAsync(Guid subscriptionId);

    /// <summary>
    /// Get subscription update information
    /// </summary>
    Task<SubscriptionUpdate> GetSubscriptionUpdateAsync(Guid subscriptionId);

    /// <summary>
    /// Update subscription update information
    /// </summary>
    Task UpdateSubscriptionUpdateAsync(SubscriptionUpdate subscriptionUpdate);

    /// <summary>
    /// Get subscription update history
    /// </summary>
    Task<IEnumerable<SubscriptionUpdate>> GetSubscriptionUpdateHistoryAsync(
        Guid? subscriptionId = null,
        int skip = 0,
        int take = 100);

    /// <summary>
    /// Check if a subscription exists
    /// </summary>
    Task<bool> SubscriptionExistsAsync(Guid subscriptionId);

    /// <summary>
    /// Get subscriptions by channel
    /// </summary>
    Task<IEnumerable<Subscription>> GetSubscriptionsByChannelAsync(int channelId);

    /// <summary>
    /// Get enabled subscriptions only
    /// </summary>
    Task<IEnumerable<Subscription>> GetEnabledSubscriptionsAsync();

    /// <summary>
    /// Bulk update subscriptions
    /// </summary>
    Task UpdateSubscriptionsAsync(IEnumerable<Subscription> subscriptions);
}