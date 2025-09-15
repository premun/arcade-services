// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Data.Models.Sqlite;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Maestro.Data;

/// <summary>
/// Design-time factory for SQLite subscription context
/// </summary>
public class SqliteSubscriptionContextFactory : IDesignTimeDbContextFactory<SqliteSubscriptionContext>
{
    public SqliteSubscriptionContext CreateDbContext(string[] args)
    {
        var connection = new SqliteConnection("Data Source=Subscriptions;Mode=Memory;Cache=Shared");
        connection.Open();

        var options = new DbContextOptionsBuilder<SqliteSubscriptionContext>()
            .UseSqlite(connection)
            .Options;

        return new SqliteSubscriptionContext(options);
    }
}

/// <summary>
/// SQLite-based Entity Framework context for ephemeral subscription storage
/// This context stores subscriptions only during service runtime and does not persist across restarts
/// </summary>
public class SqliteSubscriptionContext : DbContext
{
    public SqliteSubscriptionContext(DbContextOptions<SqliteSubscriptionContext> options)
        : base(options)
    {
    }

    public DbSet<SqliteSubscription> Subscriptions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure SQLite subscriptions
        modelBuilder.Entity<SqliteSubscription>(entity =>
        {
            entity.HasKey(s => s.Id);
            entity.Property(s => s.Id).ValueGeneratedNever(); // We'll generate GUIDs in application code
            entity.Property(s => s.SourceRepository).IsRequired();
            entity.Property(s => s.TargetRepository).IsRequired();
            entity.Property(s => s.TargetBranch).IsRequired();
            entity.Property(s => s.PolicyString);
            entity.Property(s => s.ExcludedAssetsString);
            entity.Property(s => s.CreatedAt).IsRequired();
            entity.Property(s => s.UpdatedAt).IsRequired();

            // Indexes for common queries
            entity.HasIndex(s => s.ChannelId);
            entity.HasIndex(s => s.SourceRepository);
            entity.HasIndex(s => s.TargetRepository);
            entity.HasIndex(s => new { s.SourceRepository, s.TargetRepository, s.TargetBranch });
            entity.HasIndex(s => s.Enabled);
        });

        // NOTE: SubscriptionUpdate configuration removed - moved back to SQL Server
    }

    /// <summary>
    /// Ensures the database is created and ready for use
    /// Should be called at service startup
    /// </summary>
    public void EnsureCreated()
    {
        Database.EnsureCreated();
    }

    /// <summary>
    /// Clears all subscription data (useful for testing or service restart)
    /// </summary>
    public void ClearAllData()
    {
        Subscriptions.RemoveRange(Subscriptions);
        SaveChanges();
    }
}
