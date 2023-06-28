// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace SubscriptionActorService;

public interface IActionRunner
{
    Task<string> RunAction<T>(T tracker, string method, string arguments) where T : IActionTracker;

    Task<T> ExecuteAction<T>(Expression<Func<Task<ActionResult<T>>>> actionExpression);
}
