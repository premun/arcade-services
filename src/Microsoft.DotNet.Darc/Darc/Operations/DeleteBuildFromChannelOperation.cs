// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class DeleteBuildFromChannelOperation : Operation
{
    private readonly DeleteBuildFromChannelCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly ILogger<DeleteBuildFromChannelOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public DeleteBuildFromChannelOperation(
        DeleteBuildFromChannelCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<DeleteBuildFromChannelOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    /// <summary>
    ///     Deletes a build from a channel.
    /// </summary>
    /// <returns>Process exit code.</returns>
    public override async Task<int> ExecuteAsync()
    {
        try
        {
            // Find the build to give someone info
            var build = await _consoleUI.StatusAsync(
                $"Looking up build '{_options.Id}'...",
                async ctx => await _barClient.GetBuildAsync(_options.Id));

            if (build == null)
            {
                _consoleUI.WriteError($"Could not find a build with id '{_options.Id}'");
                return Constants.ErrorCode;
            }

            Channel targetChannel = await UxHelpers.ResolveSingleChannel(_barClient, _options.Channel);
            if (targetChannel == null)
            {
                return Constants.ErrorCode;
            }

            if (!build.Channels.Any(c => c.Id == targetChannel.Id))
            {
                _consoleUI.WriteInfo($"Build '{build.Id}' is not assigned to channel '{targetChannel.Name}'");
                return Constants.SuccessCode;
            }

            _consoleUI.WriteLine($"Deleting the following build from channel '{targetChannel.Name}':");
            _consoleUI.WriteLine();
            _consoleUI.Write(UxHelpers.GetTextBuildDescription(build));

            await _consoleUI.StatusAsync(
                $"Removing build from channel...",
                async ctx =>
                {
                    await _barClient.DeleteBuildFromChannelAsync(_options.Id, targetChannel.Id);
                });

            // Let the user know they can trigger subscriptions if they'd like.
            _consoleUI.WriteInfo("Subscriptions can be triggered to revert to the previous state using the following command:");
            _consoleUI.WriteLine($"darc trigger-subscriptions --source-repo {build.GetRepository()} --channel {targetChannel.Name}");

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Error: Failed to delete build '{_options.Id}' from channel '{_options.Channel}': {e.Message}");
            _logger.LogError(e, $"Error: Failed to delete build '{_options.Id}' from channel '{_options.Channel}'.");
            return Constants.ErrorCode;
        }
    }
}
