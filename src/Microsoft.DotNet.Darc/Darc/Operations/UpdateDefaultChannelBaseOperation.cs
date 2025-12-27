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
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.DotNet.Services.Utility;

namespace Microsoft.DotNet.Darc.Operations;

internal abstract class UpdateDefaultChannelBaseOperation : Operation
{
    protected readonly IBarApiClient _barClient;
    protected readonly IConsoleUI _consoleUI;
    private readonly IUpdateDefaultChannelBaseCommandLineOptions _options;

    public UpdateDefaultChannelBaseOperation(IUpdateDefaultChannelBaseCommandLineOptions options, IBarApiClient barClient, IConsoleUI consoleUI)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
    }

    /// <summary>
    ///     Resolve channel based on the input options. If no channel could be resolved
    ///     based on the input options, returns null.
    /// </summary>
    /// <returns>Default channel or null</returns>
    protected async Task<DefaultChannel> ResolveSingleChannel()
    {
        IEnumerable<DefaultChannel> potentialDefaultChannels = await _barClient.GetDefaultChannelsAsync();
            
        // User should have supplied id or a combo of the channel name, repo, and branch.
        if (_options.Id != -1)
        {
            DefaultChannel defaultChannel = potentialDefaultChannels.SingleOrDefault(d => d.Id == _options.Id);
            if (defaultChannel == null)
            {
                _consoleUI.WriteError($"Could not find a default channel with id {_options.Id}");
            }
            return defaultChannel;
        }
        else if (string.IsNullOrEmpty(_options.Repository) ||
                 string.IsNullOrEmpty(_options.Channel) ||
                 string.IsNullOrEmpty(_options.Branch))
        {
            _consoleUI.WriteError("Please specify either the default channel id with --id or a combination of --channel, --branch and --repo");
            return null;
        }

        // Otherwise, filter based on the other inputs. If more than one resolves, then print the possible
        // matches and return null
        var matchingChannels = potentialDefaultChannels.Where(d =>
        {
            return (string.IsNullOrEmpty(_options.Repository) || d.Repository.Contains(_options.Repository, StringComparison.OrdinalIgnoreCase)) &&
                   (string.IsNullOrEmpty(_options.Channel) || d.Channel.Name.Contains(_options.Channel, StringComparison.OrdinalIgnoreCase)) &&
                   (string.IsNullOrEmpty(_options.Branch) || d.Branch.Contains(GitHelpers.NormalizeBranchName(_options.Branch), StringComparison.OrdinalIgnoreCase));
        });

        if (!matchingChannels.Any())
        {
            _consoleUI.WriteError($"No channels found matching the specified criteria.");
            return null;
        }
        else if (matchingChannels.Count() != 1)
        {
            _consoleUI.WriteError($"More than one channel matching the specified criteria. Please change your options to be more specific.");
            foreach (DefaultChannel defaultChannel in matchingChannels)
            {
                _consoleUI.WriteLine($"    {UxHelpers.GetDefaultChannelDescriptionString(defaultChannel)}");
            }
            return null;
        }
        else
        {
            return matchingChannels.Single();
        }
    }
}
