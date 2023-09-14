// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading;
using System.Threading.Tasks;

namespace Maestro.Contracts;

public interface IDependencyUpdater
{
    Task StartSubscriptionUpdateAsync(Guid subscription);

    Task StartSubscriptionUpdateForSpecificBuildAsync(Guid subscription, int buildId);

    /// <summary>
    ///     Temporary method for debugging daily update issues
    /// </summary>
    /// <param name="cancellationToken"></param>
    /// <returns></returns>
    Task CheckDailySubscriptionsAsync(CancellationToken cancellationToken);
}
