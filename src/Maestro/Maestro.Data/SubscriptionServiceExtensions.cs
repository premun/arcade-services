// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using Maestro.Data.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Maestro.Data;

/// <summary>
/// Extension methods for registering subscription services
/// </summary>
public static class SubscriptionServiceExtensions
{
    /// <summary>
    /// Register SQLite-based subscription service for ephemeral storage
    /// </summary>
    public static IServiceCollection AddSqliteSubscriptionService(this IServiceCollection services)
    {
        services.AddDbContext<SqliteSubscriptionContext>(options =>
        {
            var connection = new SqliteConnection("Data Source=Subscriptions;Mode=Memory;Cache=Shared");
            connection.Open();

            options.UseSqlite(connection);
            options.EnableSensitiveDataLogging(false);
            options.EnableServiceProviderCaching();
        });

        services.AddScoped<ISubscriptionService, SqliteSubscriptionService>();

        return services;
    }

    /// <summary>
    /// Initialize the SQLite subscription database
    /// Should be called at application startup
    /// </summary>
    public static void InitializeSqliteSubscriptionDatabase(this IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<SqliteSubscriptionContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<SqliteSubscriptionContext>>();

        try
        {
            context.EnsureCreated();
            logger.LogInformation("SQLite subscription database initialized successfully");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to initialize SQLite subscription database");
            throw;
        }
    }
}
