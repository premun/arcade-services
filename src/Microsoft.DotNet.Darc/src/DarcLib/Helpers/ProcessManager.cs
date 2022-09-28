// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;
using System.Threading.Tasks;
using System.Threading;

#nullable enable
namespace Microsoft.DotNet.DarcLib.Helpers;

public class ProcessManager : IProcessManager
{
    private readonly ILogger _logger;

    public ProcessManager(ILogger<IProcessManager> logger)
    {
        _logger = logger;
    }

    public async Task<ProcessExecutionResult> Execute(
        string executable,
        IEnumerable<string> arguments,
        TimeSpan? timeout = null,
        string? workingDir = null,
        CancellationToken cancellationToken = default)
    {
        var processStartInfo = new ProcessStartInfo()
        {
            FileName = executable,
            CreateNoWindow = true,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            WorkingDirectory = workingDir,
        };

        foreach (var arg in arguments)
        {
            processStartInfo.ArgumentList.Add(arg);
        }

        _logger.LogDebug("Executing command: '{executable} {arguments}'{workingDir}",
            executable,
            string.Join(' ', processStartInfo.ArgumentList),
            workingDir is null ? string.Empty : " in " + workingDir);

        var p = new Process() { StartInfo = processStartInfo };

        var standardOut = new StringBuilder();
        var standardErr = new StringBuilder();

        p.OutputDataReceived += delegate (object sender, DataReceivedEventArgs e)
        {
            lock (standardOut)
            {
                if (e.Data != null)
                {
                    standardOut.AppendLine(e.Data);
                }
            }
        };

        p.ErrorDataReceived += delegate (object sender, DataReceivedEventArgs e)
        {
            lock (standardErr)
            {
                if (e.Data != null)
                {
                    standardErr.AppendLine(e.Data);
                }
            }
        };

        p.Start();
        p.BeginOutputReadLine();
        p.BeginErrorReadLine();

        bool timedOut = false;
        int exitCode;
        var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);

        if (timeout.HasValue)
        {
            cts.CancelAfter((int) Math.Min(timeout.Value.TotalMilliseconds, int.MaxValue));
        }

        await p.WaitForExitAsync(cts.Token);

        if (cts.IsCancellationRequested)
        {
            _logger.LogError("Waiting for command timed out");
            timedOut = true;
            exitCode = -2;

            // try to terminate the process
            try { p.Kill(); } catch { }
        }
        else
        {
            // we exited normally, call WaitForExit() again to ensure redirected standard output is processed
            await p.WaitForExitAsync();
            exitCode = p.ExitCode;
        }

        p.Close();

        lock (standardOut)
            lock (standardErr)
            {
                return new ProcessExecutionResult()
                {
                    ExitCode = exitCode,
                    StandardOutput = standardOut.ToString(),
                    StandardError = standardErr.ToString(),
                    TimedOut = timedOut
                };
            }
    }
}
