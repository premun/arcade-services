// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class DeleteChannelOperation : Operation
{
    private readonly IBarApiClient _barClient;
    private readonly DeleteChannelCommandLineOptions _options;
    private readonly ILogger<DeleteChannelOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public DeleteChannelOperation(
        DeleteChannelCommandLineOptions options,
        ILogger<DeleteChannelOperation> logger,
        IBarApiClient barClient,
        IConsoleUI consoleUI)
    {
        _options = options;
        _logger = logger;
        _barClient = barClient;
        _consoleUI = consoleUI;
    }

    /// <summary>
    /// Deletes a channel by name
    /// </summary>
    /// <returns></returns>
    public override async Task<int> ExecuteAsync()
    {
        try
        {
            // Get the ID of the channel with the specified name.
            var existingChannel = await _consoleUI.StatusAsync(
                $"Looking up channel '{_options.Name}'...",
                async ctx =>
                {
                    var channels = await _barClient.GetChannelsAsync();
                    return channels.Where(channel => channel.Name.Equals(_options.Name, StringComparison.OrdinalIgnoreCase)).FirstOrDefault();
                });

            if (existingChannel == null)
            {
                _consoleUI.WriteError($"Could not find channel with name '{_options.Name}'");
                return Constants.ErrorCode;
            }

            await _consoleUI.StatusAsync(
                $"Deleting channel '{existingChannel.Name}'...",
                async ctx =>
                {
                    ctx.Log($"Channel ID: {existingChannel.Id}");
                    await _barClient.DeleteChannelAsync(existingChannel.Id);
                });

            _consoleUI.WriteSuccess($"Successfully deleted channel '{existingChannel.Name}'.");

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Error: Failed to delete channel: {e.Message}");
            _logger.LogError(e, "Error: Failed to delete channel.");
            return Constants.ErrorCode;
        }
    }
}
