// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class UpdateBuildOperation : Operation
{
    private readonly UpdateBuildCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly ILogger<UpdateBuildOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public UpdateBuildOperation(
        UpdateBuildCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<UpdateBuildOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    public override async Task<int> ExecuteAsync()
    {
        if (!(_options.Released ^ _options.NotReleased))
        {
            _consoleUI.WriteError("Please specify either --released or --not-released.");
            return Constants.ErrorCode;
        }

        try
        {
            var updatedBuild = await _consoleUI.StatusAsync(
                "Updating build...",
                async ctx =>
                {
                    ctx.Log($"Build ID: {_options.Id}");
                    ctx.Log($"Released: {_options.Released}");
                    return await _barClient.UpdateBuildAsync(_options.Id, new BuildUpdate { Released = _options.Released });
                });

            _consoleUI.WriteSuccess($"Updated build {_options.Id} with new information.");
            _consoleUI.WriteLine(UxHelpers.GetTextBuildDescription(updatedBuild));
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Failed to update build with id '{_options.Id}'");
            _logger.LogError(e, $"Error: Failed to update build with id '{_options.Id}'");
            return Constants.ErrorCode;
        }

        return Constants.SuccessCode;
    }
}
