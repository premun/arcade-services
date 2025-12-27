// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class DeleteDefaultChannelOperation : UpdateDefaultChannelBaseOperation
{
    private readonly ILogger<DeleteDefaultChannelOperation> _logger;

    public DeleteDefaultChannelOperation(
        DeleteDefaultChannelCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<DeleteDefaultChannelOperation> logger)
        : base(options, barClient, consoleUI)
    {
        _logger = logger;
    }

    public override async Task<int> ExecuteAsync()
    {
        try
        {
            DefaultChannel resolvedChannel = await ResolveSingleChannel();
            if (resolvedChannel == null)
            {
                return Constants.ErrorCode;
            }

            await _consoleUI.StatusAsync(
                $"Deleting default channel association...",
                async ctx =>
                {
                    ctx.Log($"Channel: {resolvedChannel.Channel.Name}");
                    ctx.Log($"Repository: {resolvedChannel.Repository}");
                    await _barClient.DeleteDefaultChannelAsync(resolvedChannel.Id);
                });

            _consoleUI.WriteSuccess("Default channel association deleted successfully.");
            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Error: Failed to remove the default channel association: {e.Message}");
            _logger.LogError(e, "Error: Failed remove the default channel association.");
            return Constants.ErrorCode;
        }
    }
}
