// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;

#nullable enable
namespace Microsoft.DotNet.DarcLib.Helpers;

public interface IProcessManager
{
    Task<ProcessExecutionResult> Execute(
        string executable,
        IEnumerable<string> arguments,
        TimeSpan? timeout = null,
        string? workingDir = null,
        CancellationToken cancellationToken = default);
}
