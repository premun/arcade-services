// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Maestro.Common;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class VerifyOperation : Operation
{
    private readonly VerifyCommandLineOptions _options;
    private readonly IRemoteTokenProvider _remoteTokenProvider;
    private readonly ILogger<VerifyOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public VerifyOperation(
        VerifyCommandLineOptions options,
        IRemoteTokenProvider remoteTokenProvider,
        IConsoleUI consoleUI,
        ILogger<VerifyOperation> logger)
    {
        _options = options;
        _remoteTokenProvider = remoteTokenProvider;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    /// <summary>
    /// Verify that the repository has a correct dependency structure.
    /// </summary>
    /// <param name="options">Command line options</param>
    /// <returns>Process exit code.</returns>
    public override async Task<int> ExecuteAsync()
    {
        var local = new Local(_remoteTokenProvider, _logger);

        try
        {
            var result = await _consoleUI.StatusAsync(
                "Verifying dependencies...",
                async ctx =>
                {
                    ctx.Log("Checking dependency structure");
                    return await local.Verify();
                });

            if (!result)
            {
                _consoleUI.WriteError("Dependency verification failed.");
                return Constants.ErrorCode;
            }
            _consoleUI.WriteSuccess("Dependency verification succeeded.");
            return Constants.SuccessCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError("Failed to verify repository dependency state.");
            _logger.LogError(e, "Error: Failed to verify repository dependency state.");
            return Constants.ErrorCode;
        }
    }
}
