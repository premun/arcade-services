// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Contracts;

namespace Maestro.ContainerApp.Actors;

public interface IActorFactory
{
    Task<IPullRequestActor> CreatePullRequestActor(string repository, string branch);
    Task<IPullRequestActor> CreatePullRequestActor(Guid subscriptionId);

    Task<ISubscriptionActor> CreateSubscriptionActor(Guid subscriptionId);
}

public class ActorFactory : IActorFactory
{
    private readonly IServiceProvider _serviceProvider;

    public ActorFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public Task<IPullRequestActor> CreatePullRequestActor(string repository, string branch)
    {
        return Task.FromResult<IPullRequestActor>(_serviceProvider.GetRequiredService<BatchedPullRequestActorImplementation>());
    }

    public Task<IPullRequestActor> CreatePullRequestActor(Guid subscriptionId)
    {
        return Task.FromResult<IPullRequestActor>(_serviceProvider.GetRequiredService<NonBatchedPullRequestActorImplementation>());
    }

    public Task<ISubscriptionActor> CreateSubscriptionActor(Guid subscriptionId)
    {
        throw new NotImplementedException();
    }
}
