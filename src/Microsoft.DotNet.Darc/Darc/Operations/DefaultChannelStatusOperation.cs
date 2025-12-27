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

internal class DefaultChannelStatusOperation : UpdateDefaultChannelBaseOperation
{
    private readonly DefaultChannelStatusCommandLineOptions _options;
    private readonly ILogger<DefaultChannelStatusOperation> _logger;

    public DefaultChannelStatusOperation(
        DefaultChannelStatusCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<DefaultChannelStatusOperation> logger)
        : base(options, barClient, consoleUI)
    {
        _options = options;
        _logger = logger;
    }

    /// <summary>
    /// Implements the default channel enable/disable operation
    /// </summary>
    public override async Task<int> ExecuteAsync()
    {
        if ((_options.Enable && _options.Disable) ||
            (!_options.Enable && !_options.Disable))
        {
            _consoleUI.WriteError("Please specify either --enable or --disable");
            return Constants.ErrorCode;
        }

        try
        {
            DefaultChannel resolvedChannel = await ResolveSingleChannel();
            if (resolvedChannel == null)
            {
                return Constants.ErrorCode;
            }

            bool enabled;
            if (_options.Enable)
            {
                if (resolvedChannel.Enabled)
                {
                    _consoleUI.WriteInfo($"Default channel association is already enabled");
                    return Constants.ErrorCode;
                }
                enabled = true;
            }
            else
            {
                if (!resolvedChannel.Enabled)
                {
                    _consoleUI.WriteInfo($"Default channel association is already disabled");
                    return Constants.ErrorCode;
                }
                enabled = false;
            }

            await _barClient.UpdateDefaultChannelAsync(resolvedChannel.Id, enabled: enabled);

            _consoleUI.WriteSuccess($"Default channel association has been {(enabled ? "enabled" : "disabled")}.");

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError("Failed enable/disable default channel association.");
            _logger.LogError(e, "Error: Failed enable/disable default channel association.");
            return Constants.ErrorCode;
        }
    }
}
