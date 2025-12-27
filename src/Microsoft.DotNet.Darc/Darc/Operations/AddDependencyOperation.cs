// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.IO;
using System.Threading.Tasks;
using Maestro.Common;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.DarcLib.Helpers;
using Microsoft.DotNet.DarcLib.Models.Darc;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class AddDependencyOperation : Operation
{
    private readonly AddDependencyCommandLineOptions _options;
    private readonly IRemoteTokenProvider _tokenProvider;
    private readonly ILogger<AddDependencyOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public AddDependencyOperation(
        AddDependencyCommandLineOptions options,
        IRemoteTokenProvider tokenProvider,
        IConsoleUI consoleUI,
        ILogger<AddDependencyOperation> logger)
    {
        _options = options;
        _tokenProvider = tokenProvider;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    public override async Task<int> ExecuteAsync()
    {
        DependencyType type = _options.Type.Equals("toolset", StringComparison.CurrentCultureIgnoreCase)
            ? DependencyType.Toolset
            : DependencyType.Product;

        var local = new Local(_tokenProvider, _logger);

        var dependency = new DependencyDetail
        {
            Name = _options.Name,
            Version = _options.Version ?? string.Empty,
            RepoUri = _options.RepoUri ?? string.Empty,
            Commit = _options.Commit ?? string.Empty,
            CoherentParentDependencyName = _options.CoherentParentDependencyName ?? string.Empty,
            Pinned = _options.Pinned,
            SkipProperty = _options.SkipProperty,
            Type = type,
        };

        try
        {
            await _consoleUI.StatusAsync(
                $"Adding dependency '{dependency.Name}'...",
                async ctx =>
                {
                    ctx.Log($"Version: {dependency.Version}");
                    ctx.Log($"Type: {type}");
                    await local.AddDependencyAsync(
                        dependency,
                        _options.RelativeBasePath != null
                            ? new UnixPath(_options.RelativeBasePath)
                            : null);
                });

            _consoleUI.WriteSuccess($"Dependency '{dependency.Name}' added successfully.");
            return Constants.SuccessCode;
        }
        catch (FileNotFoundException exc)
        {
            _consoleUI.WriteError($"One of the version files is missing. Please make sure to add all files " +
                                 "included in https://github.com/dotnet/arcade/blob/main/Documentation/DependencyDescriptionFormat.md#dependency-description-details");
            _logger.LogError(exc, "Version file missing.");
            return Constants.ErrorCode;
        }
        catch (Exception exc)
        {
            _consoleUI.WriteError($"Failed to add dependency '{dependency.Name}' to repository: {exc.Message}");
            _logger.LogError(exc, $"Failed to add dependency '{dependency.Name}' to repository.");
            return Constants.ErrorCode;
        }
    }
}
