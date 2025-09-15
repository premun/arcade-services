// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.Services.Utility;
using Newtonsoft.Json;

namespace Maestro.Data.Models.Sqlite;

/// <summary>
/// SQLite-specific subscription model for ephemeral storage during service runtime
/// </summary>
public class SqliteSubscription
{
    private string _sourceRepository;
    private string _targetRepository;
    private string _branch;

    [Key]
    public Guid Id { get; set; }

    public int ChannelId { get; set; }

    public string SourceRepository
    {
        get
        {
            return AzureDevOpsClient.NormalizeUrl(_sourceRepository);
        }

        set
        {
            _sourceRepository = AzureDevOpsClient.NormalizeUrl(value);
        }
    }

    public string TargetRepository
    {
        get
        {
            return AzureDevOpsClient.NormalizeUrl(_targetRepository);
        }

        set
        {
            _targetRepository = AzureDevOpsClient.NormalizeUrl(value);
        }
    }

    public string TargetBranch
    {
        get
        {
            return GitHelpers.NormalizeBranchName(_branch);
        }
        set
        {
            _branch = GitHelpers.NormalizeBranchName(value);
        }
    }

    public string PolicyString { get; set; }

    public bool Enabled { get; set; } = true;

    /// <summary>
    /// Denotes whether sources are also synchronized.
    /// Source or target repository must be a VMR.
    /// </summary>
    public bool SourceEnabled { get; set; }

    /// <summary>
    /// Denotes the directory of the VMR which are the sources synchronized from.
    /// (for VMR->repo subscriptions)
    /// Only Source or Target repository can be set at a time.
    /// </summary>
    public string SourceDirectory { get; set; }

    /// <summary>
    /// Denotes the directory in the VMR which are the sources synchronized into.
    /// (for repo->VMR subscriptions)
    /// Only Source or Target repository can be set at a time.
    /// </summary>
    public string TargetDirectory { get; set; }

    /// <summary>
    /// Serialized list of asset filters - comma separated for SQLite storage
    /// </summary>
    public string ExcludedAssetsString { get; set; }

    [NotMapped]
    public SubscriptionPolicy PolicyObject
    {
        get => PolicyString == null ? null : JsonConvert.DeserializeObject<SubscriptionPolicy>(PolicyString);
        set => PolicyString = value == null ? null : JsonConvert.SerializeObject(value);
    }

    [NotMapped]
    public List<string> ExcludedAssets
    {
        get => string.IsNullOrEmpty(ExcludedAssetsString) 
            ? [] 
            : [.. ExcludedAssetsString.Split(',', StringSplitOptions.RemoveEmptyEntries)];
        set => ExcludedAssetsString = value?.Count > 0 ? string.Join(",", value) : null;
    }

    public int? LastAppliedBuildId { get; set; }

    public string PullRequestFailureNotificationTags { get; set; }

    /// <summary>
    /// Timestamp when subscription was created in SQLite storage
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Timestamp when subscription was last updated
    /// </summary>
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Convert from SQL Server subscription model to SQLite model
    /// </summary>
    public static SqliteSubscription FromSqlSubscription(Subscription sqlSubscription)
    {
        return new SqliteSubscription
        {
            Id = sqlSubscription.Id,
            ChannelId = sqlSubscription.ChannelId,
            SourceRepository = sqlSubscription.SourceRepository,
            TargetRepository = sqlSubscription.TargetRepository,
            TargetBranch = sqlSubscription.TargetBranch,
            PolicyString = sqlSubscription.PolicyString,
            Enabled = sqlSubscription.Enabled,
            SourceEnabled = sqlSubscription.SourceEnabled,
            SourceDirectory = sqlSubscription.SourceDirectory,
            TargetDirectory = sqlSubscription.TargetDirectory,
            ExcludedAssets = sqlSubscription.ExcludedAssets?.Select(a => a.Filter).ToList() ?? [],
            LastAppliedBuildId = sqlSubscription.LastAppliedBuildId,
            PullRequestFailureNotificationTags = sqlSubscription.PullRequestFailureNotificationTags
        };
    }

    /// <summary>
    /// Convert to SQL Server subscription model for compatibility
    /// </summary>
    public Subscription ToSqlSubscription()
    {
        return new Subscription
        {
            Id = Id,
            ChannelId = ChannelId,
            SourceRepository = SourceRepository,
            TargetRepository = TargetRepository,
            TargetBranch = TargetBranch,
            PolicyString = PolicyString,
            Enabled = Enabled,
            SourceEnabled = SourceEnabled,
            SourceDirectory = SourceDirectory,
            TargetDirectory = TargetDirectory,
            ExcludedAssets = ExcludedAssets?.Select(filter => new AssetFilter { Filter = filter }).ToList() ?? [],
            LastAppliedBuildId = LastAppliedBuildId,
            PullRequestFailureNotificationTags = PullRequestFailureNotificationTags
        };
    }
}