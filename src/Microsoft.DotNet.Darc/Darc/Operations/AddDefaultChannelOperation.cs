// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.Services.Utility;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class AddDefaultChannelOperation : Operation
{
    private readonly AddDefaultChannelCommandLineOptions _options;
    private readonly ILogger<AddDefaultChannelOperation> _logger;
    private readonly IBarApiClient _barClient;
    private readonly IRemoteFactory _remoteFactory;
    private readonly IConsoleUI _consoleUI;

    public AddDefaultChannelOperation(
        AddDefaultChannelCommandLineOptions options,
        ILogger<AddDefaultChannelOperation> logger,
        IBarApiClient barClient,
        IRemoteFactory remoteFactory,
        IConsoleUI consoleUI)
    {
        _options = options;
        _logger = logger;
        _barClient = barClient;
        _remoteFactory = remoteFactory;
        _consoleUI = consoleUI;
    }

    public override async Task<int> ExecuteAsync()
    {
        try
        {
            IRemote repoRemote = await _remoteFactory.CreateRemoteAsync(_options.Repository);

            // Users can ignore the flag and pass in -regex: but to prevent typos we'll avoid that.
            _options.Branch = _options.UseBranchAsRegex ? $"-regex:{_options.Branch}" : GitHelpers.NormalizeBranchName(_options.Branch);

            if (!(await UxHelpers.VerifyAndConfirmBranchExistsAsync(repoRemote, _options.Repository, _options.Branch, !_options.NoConfirmation)))
            {
                _consoleUI.WriteWarning("Aborting default channel creation.");
                return Constants.ErrorCode;
            }

            await _consoleUI.StatusAsync(
                $"Adding default channel association...",
                async ctx =>
                {
                    ctx.Log($"Repository: {_options.Repository}");
                    ctx.Log($"Branch: {_options.Branch}");
                    ctx.Log($"Channel: {_options.Channel}");
                    await _barClient.AddDefaultChannelAsync(_options.Repository, _options.Branch, _options.Channel);
                });

            _consoleUI.WriteSuccess("Default channel association added successfully.");
            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError($"Error: Failed to add a new default channel association: {e.Message}");
            _logger.LogError(e, "Error: Failed to add a new default channel association.");
            return Constants.ErrorCode;
        }
    }
}
