// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.VirtualMonoRepo;
using Microsoft.Extensions.Logging;

#nullable enable
namespace Microsoft.DotNet.Darc.Operations.VirtualMonoRepo;

internal abstract class ScanOperationBase<T> : Operation where T : IVmrScanner
{
    private readonly IVmrScanOptions _options;
    private readonly IVmrScanner _vmrScanner;
    private readonly ILogger<ScanOperationBase<T>> _logger;
    private readonly IConsoleUI _consoleUI;

    public ScanOperationBase(
        IVmrScanOptions options,
        IVmrScanner vmrScanner,
        ILogger<ScanOperationBase<T>> logger,
        IConsoleUI consoleUI)
    {
        _options = options;
        _vmrScanner = vmrScanner;
        _logger = logger;
        _consoleUI = consoleUI;
    }

    public override async Task<int> ExecuteAsync()
    {
        using var listener = CancellationKeyListener.ListenForCancellation(_logger);

        var files = await _vmrScanner.ScanVmr(_options.BaselineFilePath, listener.Token);

        foreach (var file in files)
        {
            _consoleUI.WriteLine(file);
        }

        return files.Count != 0 ? 1 : Constants.SuccessCode;
    }
}
