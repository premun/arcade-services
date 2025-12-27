// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Maestro.Common;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.DotNet.DarcLib.Models.Darc;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class GetDependenciesOperation : Operation
{
    private readonly GetDependenciesCommandLineOptions _options;
    private readonly IRemoteTokenProvider _remoteTokenProvider;
    private readonly ILogger<GetDependenciesOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public GetDependenciesOperation(
        GetDependenciesCommandLineOptions options,
        IRemoteTokenProvider remoteTokenProvider,
        IConsoleUI consoleUI,
        ILogger<GetDependenciesOperation> logger)
    {
        _options = options;
        _remoteTokenProvider = remoteTokenProvider;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    public override async Task<int> ExecuteAsync()
    {
        var local = new Local(_remoteTokenProvider, _logger);

        try
        {
            var dependencies = await _consoleUI.StatusAsync(
                "Getting dependencies...",
                async ctx =>
                {
                    return await local.GetDependenciesAsync(
                        _options.Name,
                        relativeBasePath: _options.RelativeBasePath != null
                            ? new UnixPath(_options.RelativeBasePath)
                            : null);
                });

            if (!string.IsNullOrEmpty(_options.Name))
            {
                DependencyDetail dependency = dependencies
                    .Where(d => d.Name.Equals(_options.Name, StringComparison.InvariantCultureIgnoreCase))
                    .FirstOrDefault()
                    ?? throw new Exception($"A dependency with name '{_options.Name}' was not found...");

                LogDependency(dependency);
            }

            foreach (DependencyDetail dependency in dependencies)
            {
                LogDependency(dependency);

                _consoleUI.WriteLine();
            }

            return Constants.SuccessCode;
        }
        catch (Exception exc)
        {
            if (!string.IsNullOrEmpty(_options.Name))
            {
                _consoleUI.WriteError($"Something failed while querying for local dependency '{_options.Name}': {exc.Message}");
                _logger.LogError(exc, $"Something failed while querying for local dependency '{_options.Name}'.");
            }
            else
            {
                _consoleUI.WriteError($"Something failed while querying for local dependencies: {exc.Message}");
                _logger.LogError(exc, "Something failed while querying for local dependencies.");
            }
                
            return Constants.ErrorCode;
        }
    }

    private void LogDependency(DependencyDetail dependency)
    {
        _consoleUI.Write(UxHelpers.DependencyToString(dependency));
    }
}
