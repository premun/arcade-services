// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Microsoft.DotNet.Darc.Operations;

internal class GetChannelOperation : Operation
{
    private readonly GetChannelCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly ILogger<GetChannelOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public GetChannelOperation(
        GetChannelCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<GetChannelOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    /// <summary>
    /// Retrieve information about a specific channel
    /// </summary>
    /// <param name="options">Command line options</param>
    /// <returns>Process exit code.</returns>
    public override async Task<int> ExecuteAsync()
    {
        try
        {
            var channel = await _consoleUI.StatusAsync(
                $"Retrieving channel {_options.Id}...",
                async ctx => await _barClient.GetChannelAsync(_options.Id));

            if (channel == null)
            {
                _consoleUI.WriteError($"Channel with id {_options.Id} not found");
                return Constants.ErrorCode;
            }

            switch (_options.OutputFormat)
            {
                case DarcOutputType.json:
                    _consoleUI.WriteLine(JsonConvert.SerializeObject(channel, Formatting.Indented));
                    break;
                case DarcOutputType.text:
                    _consoleUI.WriteLine($"({channel.Id}) {channel.Name}");
                    break;
                default:
                    throw new NotImplementedException($"Output format {_options.OutputFormat} not supported for get-channel");
            }

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Error: Failed to retrieve the channel: {e.Message}");
            _logger.LogError(e, "Error: Failed to retrieve the channel");
            return Constants.ErrorCode;
        }
    }
}
