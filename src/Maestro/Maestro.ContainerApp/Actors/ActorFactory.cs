// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Contracts;

namespace Maestro.ContainerApp.Actors;

public interface IActorFactory
{
    IPullRequestActor CreatePullRequestActor(string repository, string branch);
    IPullRequestActor CreatePullRequestActor(Guid subscriptionId);

    ISubscriptionActor CreateSubscriptionActor(Guid subscriptionId);
}

public class ActorFactory : IActorFactory
{
    private readonly IServiceProvider _serviceProvider;

    public ActorFactory(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public IPullRequestActor CreatePullRequestActor(string repository, string branch)
    {
        return ActivatorUtilities.CreateInstance<BatchedPullRequestActor>(_serviceProvider, new PullRequestActorId(repository, branch));
    }

    public IPullRequestActor CreatePullRequestActor(Guid subscriptionId)
    {
        return ActivatorUtilities.CreateInstance<NonBatchedPullRequestActor>(_serviceProvider, new PullRequestActorId(subscriptionId));
    }

    public ISubscriptionActor CreateSubscriptionActor(Guid subscriptionId)
    {
        throw new NotImplementedException();
    }
}
