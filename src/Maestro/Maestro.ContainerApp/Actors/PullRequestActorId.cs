// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Text;

namespace Maestro.ContainerApp.Actors;

/// <summary>
///     A factory that creates <see cref="ActorId" /> instances for PullRequestActors
/// </summary>
public class PullRequestActorId
{
    public string Id { get; private set; }
    /// <summary>
    ///     Creates an <see cref="ActorId" /> identifying the PullRequestActor responsible for pull requests for the
    ///     non-batched subscription
    ///     referenced by <see paramref="subscriptionId" />.
    /// </summary>
    public PullRequestActorId(Guid subscriptionId)
    {
        Id = subscriptionId.ToString();
    }

    /// <summary>
    ///     Creates an <see cref="ActorId" /> identifying the PullRequestActor responsible for pull requests for all batched
    ///     subscriptions
    ///     targeting the (<see paramref="repository" />, <see paramref="branch" />) pair.
    /// </summary>
    public PullRequestActorId(string repository, string branch)
    {
        Id = Encode(repository) + ":" + Encode(branch);
    }

    /// <summary>
    ///     Parses an <see cref="ActorId" /> created by <see cref="Create(string, string)" /> into the (repository, branch)
    ///     pair that created it.
    /// </summary>
    public (string repository, string branch) Parse()
    {
        if (string.IsNullOrEmpty(Id))
        {
            throw new ArgumentException("Actor id must be a string kind", nameof(Id));
        }

        int colonIndex = Id.IndexOf(":", StringComparison.Ordinal);

        if (colonIndex == -1)
        {
            throw new ArgumentException("Actor id not in correct format", nameof(Id));
        }

        string repository = Decode(Id.Substring(0, colonIndex));
        string branch = Decode(Id.Substring(colonIndex + 1));
        return (repository, branch);
    }

    private static string Encode(string repository)
    {
        return Convert.ToBase64String(Encoding.UTF8.GetBytes(repository));
    }

    private static string Decode(string value)
    {
        return Encoding.UTF8.GetString(Convert.FromBase64String(value));
    }
}
