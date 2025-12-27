// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Net;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class GetGoalOperation : Operation
{
    private readonly GetGoalCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly ILogger<GetGoalOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public GetGoalOperation(
        GetGoalCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<GetGoalOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    /// <summary>
    /// Retrieve Goal in minutes for Definition in a Channel.
    /// </summary>
    /// <returns>Process exit code.</returns>
    public override async Task<int> ExecuteAsync()
    {
        try
        {
            var goalInfo = await _consoleUI.StatusAsync(
                "Retrieving goal...",
                async ctx =>
                {
                    ctx.Log($"Channel: {_options.Channel}");
                    ctx.Log($"Definition ID: {_options.DefinitionId}");
                    return await _barClient.GetGoalAsync(_options.Channel, _options.DefinitionId);
                });

            _consoleUI.Write(goalInfo.Minutes.ToString());
            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (RestApiException e) when (e.Response.Status == (int)HttpStatusCode.NotFound)
        {
            _consoleUI.WriteError($"Cannot find Channel '{_options.Channel}'.");
            _logger.LogError(e, $"Cannot find Channel '{_options.Channel}'.");
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Unable to get goal for Channel : '{_options.Channel}' and DefinitionId : '{_options.DefinitionId}': {e.Message}");
            _logger.LogError(e, $"Unable to create goal for Channel : '{_options.Channel}' and DefinitionId : '{_options.DefinitionId}'.");
            return Constants.ErrorCode;
        }
    }
}
