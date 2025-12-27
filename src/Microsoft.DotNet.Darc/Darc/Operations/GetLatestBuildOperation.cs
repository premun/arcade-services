// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;

namespace Microsoft.DotNet.Darc.Operations;

internal class GetLatestBuildOperation : Operation
{
    private readonly GetLatestBuildCommandLineOptions _options;
    private readonly IBarApiClient _barClient;
    private readonly IConsoleUI _consoleUI;

    public GetLatestBuildOperation(
        GetLatestBuildCommandLineOptions options,
        IBarApiClient barClient,
        IConsoleUI consoleUI)
    {
        _options = options;
        _barClient = barClient;
        _consoleUI = consoleUI;
    }

    /// <summary>
    ///     Gets the latest build for a repo
    /// </summary>
    /// <returns>Process exit code.</returns>
    public override async Task<int> ExecuteAsync()
    {
        // We only print to console if the output format is not JSON
        var outputJson = _options.OutputFormat == DarcOutputType.json;

        try
        {
            // Calculate out possible repos based on the input strings.
            // Today the DB has no way of searching for builds by substring, so for now
            // grab source/targets repos of subscriptions matched on substring,
            // and then add the explicit repo from the options.
            // Then search channels by substring
            // Then run GetLatestBuild for each permutation.

            var subscriptions = await _barClient.GetSubscriptionsAsync();
            var possibleRepos = subscriptions
                .SelectMany(subscription => new List<string> { subscription.SourceRepository, subscription.TargetRepository })
                .Where(r => r.Contains(_options.Repo, StringComparison.OrdinalIgnoreCase))
                .ToHashSet(StringComparer.OrdinalIgnoreCase);
            possibleRepos.Add(_options.Repo);

            var channels = (await _barClient.GetChannelsAsync())
                .Where(c => string.IsNullOrEmpty(_options.Channel) || c.Name.Contains(_options.Channel, StringComparison.OrdinalIgnoreCase))
                .ToList();

            if (channels.Count == 0)
            {
                if (!outputJson)
                {
                    _consoleUI.WriteWarning($"Could not find a channel with name containing '{_options.Channel}'");
                }
                return Constants.ErrorCode;
            }

            var latestBuildTasks = possibleRepos.SelectMany(repo => channels
                .Select(channel => _barClient.GetLatestBuildAsync(repo, channel.Id)));

            var latestBuilds = (await Task.WhenAll(latestBuildTasks))
                .Where(build => build != null)
                .ToList();

            if (latestBuilds.Count == 0)
            {
                if (!outputJson)
                {
                    _consoleUI.WriteWarning("No latest build found matching the specified criteria");
                }
                return Constants.ErrorCode;
            }

            if (outputJson)
            {
                _consoleUI.WriteLine("[");
                _consoleUI.WriteLine(string.Join(
                    "," + Environment.NewLine,
                    latestBuilds.Select(UxHelpers.GetJsonBuildDescription)));
                _consoleUI.WriteLine("]");
            }
            else
            {
                _consoleUI.WriteLine(string.Join(
                    Environment.NewLine + Environment.NewLine,
                    latestBuilds.Select(UxHelpers.GetTextBuildDescription)));
            }

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            if (!outputJson)
            {
                _consoleUI.WriteError(e.Message);
            }
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            if (!outputJson)
            {
                _consoleUI.WriteError("Failed to retrieve latest build: " + e.Message);
            }
            return Constants.ErrorCode;
        }
    }
}
