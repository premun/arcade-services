// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Microsoft.DotNet.Darc.Operations;

/// <summary>
/// Implements an operation to get information about the default channel associations.
/// </summary>
internal class GetDefaultChannelsOperation : Operation
{
    private readonly GetDefaultChannelsCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly ILogger<GetDefaultChannelsOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public GetDefaultChannelsOperation(
        GetDefaultChannelsCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI,
        ILogger<GetDefaultChannelsOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    /// <summary>
    /// Retrieve information about the default association between builds of a specific branch/repo
    /// and a channel.
    /// </summary>
    /// <returns></returns>
    public override async Task<int> ExecuteAsync()
    {
        try
        {
            var defaultChannels = await _consoleUI.StatusAsync(
                "Retrieving default channels...",
                async ctx => await FilterDefaultChannels());

            if (!defaultChannels.Any())
            {
                _consoleUI.WriteWarning("No matching channels were found.");
            }

            switch (_options.OutputFormat)
            {
                case DarcOutputType.json:
                    _consoleUI.WriteLine(JsonConvert.SerializeObject(defaultChannels, Formatting.Indented));
                    break;
                case DarcOutputType.text:
                    // Write out a simple list of each channel's name
                    foreach (DefaultChannel defaultChannel in defaultChannels)
                    {
                        _consoleUI.WriteLine(UxHelpers.GetDefaultChannelDescriptionString(defaultChannel));
                    }
                    break;
                default:
                    throw new NotImplementedException($"Output type {_options.OutputFormat} not supported by get-subscriptions");
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
            _consoleUI.WriteError($"Error: Failed to retrieve default channel information: {e.Message}");
            _logger.LogError(e, "Error: Failed to retrieve default channel information.");
            return Constants.ErrorCode;
        }
    }

    private async Task<IEnumerable<DefaultChannel>> FilterDefaultChannels() => (await _barClient.GetDefaultChannelsAsync())
                    .Where(defaultChannel =>
                    {
                        return  (_options.Ids == null || !_options.Ids.Any() || _options.Ids.Any(id => id.Equals(defaultChannel.Id.ToString()))) &&
                                (string.IsNullOrEmpty(_options.SourceRepository) ||
                                defaultChannel.Repository.Contains(_options.SourceRepository, StringComparison.OrdinalIgnoreCase)) &&
                               (string.IsNullOrEmpty(_options.Branch) ||
                                defaultChannel.Branch.Contains(_options.Branch, StringComparison.OrdinalIgnoreCase)) &&
                               (string.IsNullOrEmpty(_options.Channel) ||
                                defaultChannel.Channel.Name.Contains(_options.Channel, StringComparison.OrdinalIgnoreCase));
                    })
                    .OrderBy(df => df.Repository);
}
