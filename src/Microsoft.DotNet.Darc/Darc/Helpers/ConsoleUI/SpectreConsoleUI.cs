// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Spectre.Console;

namespace Microsoft.DotNet.Darc.Helpers.ConsoleUI;

/// <summary>
/// Spectre.Console-based implementation for interactive terminal UI.
/// Provides spinners, colored output, and rich formatting.
/// </summary>
public class SpectreConsoleUI : IConsoleUI
{
    private readonly IAnsiConsole _console;

    public bool IsInteractive => true;

    public SpectreConsoleUI()
    {
        _console = AnsiConsole.Create(new AnsiConsoleSettings
        {
            Ansi = AnsiSupport.Detect,
            ColorSystem = ColorSystemSupport.Detect
        });
    }

    public async Task<T> StatusAsync<T>(string statusText, Func<IStatusContext, Task<T>> action)
    {
        T result = default!;
        await _console.Status()
            .Spinner(Spinner.Known.Dots)
            .SpinnerStyle(Style.Parse("green"))
            .StartAsync(statusText, async ctx =>
            {
                var statusContext = new SpectreStatusContext(ctx, _console);
                result = await action(statusContext);
            });
        return result;
    }

    public async Task StatusAsync(string statusText, Func<IStatusContext, Task> action)
    {
        await _console.Status()
            .Spinner(Spinner.Known.Dots)
            .SpinnerStyle(Style.Parse("green"))
            .StartAsync(statusText, async ctx =>
            {
                var statusContext = new SpectreStatusContext(ctx, _console);
                await action(statusContext);
            });
    }

    public void WriteInfo(string message)
        => _console.MarkupLine($"[blue]ℹ[/] {message.EscapeMarkup()}");

    public void WriteWarning(string message)
        => _console.MarkupLine($"[yellow]⚠[/] {message.EscapeMarkup()}");

    public void WriteError(string message)
        => _console.MarkupLine($"[red]✗[/] {message.EscapeMarkup()}");

    public void WriteSuccess(string message)
        => _console.MarkupLine($"[green]✓[/] {message.EscapeMarkup()}");

    public void Write(string message)
        => _console.Write(message);

    public void WriteLine(string message = "")
        => _console.WriteLine(message);
}

/// <summary>
/// Status context implementation for Spectre.Console.
/// </summary>
internal sealed class SpectreStatusContext : IStatusContext
{
    private readonly StatusContext _ctx;
    private readonly IAnsiConsole _console;

    public SpectreStatusContext(StatusContext ctx, IAnsiConsole console)
    {
        _ctx = ctx;
        _console = console;
    }

    public void UpdateStatus(string status)
        => _ctx.Status(status);

    public void Log(string message)
        => _console.MarkupLine($"  [grey]{message.EscapeMarkup()}[/]");
}
