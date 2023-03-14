// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Options.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.VirtualMonoRepo;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

#nullable enable
namespace Microsoft.DotNet.Darc.Operations.VirtualMonoRepo;

internal class BackflowOperation : Operation
{
    private readonly VmrBackflowCommandLineOptions _options;

    public BackflowOperation(VmrBackflowCommandLineOptions options)
        : base(options, options.RegisterServices())
    {
        _options = options;
    }

    public override async Task<int> ExecuteAsync()
    {
        var backflowManager = Provider.GetRequiredService<IVmrBackflowManager>();
        using var listener = CancellationKeyListener.ListenForCancellation(Logger);

        try
        {
            await backflowManager.Backflow(listener.Token);
            return 0;
        }
        catch (Exception e)
        {
            Logger.LogError("Backflow failed. {exception}", Environment.NewLine + e.Message);
            Logger.LogDebug("{exception}", e);

            return Constants.ErrorCode;
        }
    }
}
