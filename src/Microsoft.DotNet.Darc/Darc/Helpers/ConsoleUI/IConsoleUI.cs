// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;

namespace Microsoft.DotNet.Darc.Helpers.ConsoleUI;

/// <summary>
/// Abstraction for console UI operations that can switch between
/// interactive (Spectre.Console) and plain text (CI/JSON) modes.
/// </summary>
public interface IConsoleUI
{
    /// <summary>
    /// Whether interactive UI is enabled (Spectre.Console features).
    /// </summary>
    bool IsInteractive { get; }

    /// <summary>
    /// Executes an operation with a status spinner (or plain text in CI mode).
    /// </summary>
    Task<T> StatusAsync<T>(string statusText, Func<IStatusContext, Task<T>> action);

    /// <summary>
    /// Executes an operation with a status spinner (or plain text in CI mode).
    /// </summary>
    Task StatusAsync(string statusText, Func<IStatusContext, Task> action);

    /// <summary>
    /// Writes an informational message.
    /// </summary>
    void WriteInfo(string message);

    /// <summary>
    /// Writes a warning message.
    /// </summary>
    void WriteWarning(string message);

    /// <summary>
    /// Writes an error message.
    /// </summary>
    void WriteError(string message);

    /// <summary>
    /// Writes a success message.
    /// </summary>
    void WriteSuccess(string message);

    /// <summary>
    /// Writes plain text output (for data display).
    /// </summary>
    void Write(string message);

    /// <summary>
    /// Writes plain text output with newline (for data display).
    /// </summary>
    void WriteLine(string message = "");
}

/// <summary>
/// Context for status operations that allows updating status and logging messages.
/// </summary>
public interface IStatusContext
{
    /// <summary>
    /// Updates the current status text.
    /// </summary>
    void UpdateStatus(string status);

    /// <summary>
    /// Logs a message within the current status context.
    /// </summary>
    void Log(string message);
}
