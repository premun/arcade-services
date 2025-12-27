// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Helpers.ConsoleUI;

/// <summary>
/// Plain text console UI implementation for CI environments and JSON output.
/// Uses standard console output and logging instead of Spectre.Console features.
/// </summary>
public class PlainConsoleUI : IConsoleUI
{
    private readonly ILogger _logger;

    public bool IsInteractive => false;

    public PlainConsoleUI(ILogger logger)
    {
        _logger = logger;
    }

    public async Task<T> StatusAsync<T>(string statusText, Func<IStatusContext, Task<T>> action)
    {
        _logger.LogInformation("{Status}", statusText);
        var context = new PlainStatusContext(_logger);
        return await action(context);
    }

    public async Task StatusAsync(string statusText, Func<IStatusContext, Task> action)
    {
        _logger.LogInformation("{Status}", statusText);
        var context = new PlainStatusContext(_logger);
        await action(context);
    }

    public void WriteInfo(string message)
        => _logger.LogInformation("{Message}", message);

    public void WriteWarning(string message)
        => _logger.LogWarning("{Message}", message);

    public void WriteError(string message)
        => _logger.LogError("{Message}", message);

    public void WriteSuccess(string message)
        => _logger.LogInformation("{Message}", message);

    public void Write(string message)
        => System.Console.Write(message);

    public void WriteLine(string message = "")
        => System.Console.WriteLine(message);
}

/// <summary>
/// Status context implementation for plain text output.
/// </summary>
internal sealed class PlainStatusContext : IStatusContext
{
    private readonly ILogger _logger;

    public PlainStatusContext(ILogger logger)
    {
        _logger = logger;
    }

    public void UpdateStatus(string status)
        => _logger.LogInformation("{Status}", status);

    public void Log(string message)
        => _logger.LogDebug("{Message}", message);
}
