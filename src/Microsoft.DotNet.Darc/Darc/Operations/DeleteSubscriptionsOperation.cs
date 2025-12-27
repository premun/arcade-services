// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.DotNet.Darc.Helpers;
using Microsoft.DotNet.Darc.Helpers.ConsoleUI;
using Microsoft.DotNet.Darc.Options;
using Microsoft.DotNet.DarcLib;
using Microsoft.DotNet.MaestroConfiguration.Client;
using Microsoft.DotNet.MaestroConfiguration.Client.Models;
using Microsoft.DotNet.ProductConstructionService.Client;
using Microsoft.DotNet.ProductConstructionService.Client.Models;
using Microsoft.Extensions.Logging;

namespace Microsoft.DotNet.Darc.Operations;

internal class DeleteSubscriptionsOperation : Operation
{
    private readonly IBarApiClient _barClient;
    private readonly DeleteSubscriptionsCommandLineOptions _options;
    private readonly IConfigurationRepositoryManager _configRepositoryManager;
    private readonly ILogger<DeleteSubscriptionsOperation> _logger;
    private readonly IConsoleUI _consoleUI;

    public DeleteSubscriptionsOperation(
        DeleteSubscriptionsCommandLineOptions options,
        IBarApiClient barClient,
        IConfigurationRepositoryManager configRepositoryManager,
        IConsoleUI consoleUI,
        ILogger<DeleteSubscriptionsOperation> logger)
    {
        _options = options;
        _barClient = barClient;
        _configRepositoryManager = configRepositoryManager;
        _consoleUI = consoleUI;
        _logger = logger;
    }

    public override async Task<int> ExecuteAsync()
    {
        try
        {
            bool noConfirm = _options.NoConfirmation;
            List<Subscription> subscriptionsToDelete = [];

            if (!string.IsNullOrEmpty(_options.Id))
            {
                // Look up subscription so we can print it later.
                try
                {
                    Subscription subscription = await _barClient.GetSubscriptionAsync(_options.Id);
                    subscriptionsToDelete.Add(subscription);
                }
                catch (RestApiException e) when (e.Response.Status == (int) HttpStatusCode.NotFound)
                {
                    _consoleUI.WriteError($"Subscription with id '{_options.Id}' was not found.");
                    return Constants.ErrorCode;
                }
            }
            else
            {
                if (!_options.HasAnyFilters())
                {
                    _consoleUI.WriteError($"Please specify one or more filters to select which subscriptions should be deleted (see help).");
                    return Constants.ErrorCode;
                }

                IEnumerable<Subscription> subscriptions = await _options.FilterSubscriptions(_barClient);

                if (!subscriptions.Any())
                {
                    _consoleUI.WriteWarning("No subscriptions found matching the specified criteria.");
                    return Constants.ErrorCode;
                }

                subscriptionsToDelete.AddRange(subscriptions);
            }

            if (_options.ShouldUseConfigurationRepository)
            {
                foreach (Subscription subscription in subscriptionsToDelete)
                {
                    await _configRepositoryManager.DeleteSubscriptionAsync(
                        _options.ToConfigurationRepositoryOperationParameters(),
                        SubscriptionYaml.FromClientModel(subscription));
                }
            }
            else
            {
                if (!noConfirm)
                {
                    // Print out the list of subscriptions about to be triggered.
                    _consoleUI.WriteInfo($"Will delete the following {subscriptionsToDelete.Count} subscriptions...");
                    foreach (var subscription in subscriptionsToDelete)
                    {
                        _consoleUI.WriteLine($"  {UxHelpers.GetSubscriptionDescription(subscription)}");
                    }

                    if (!UxHelpers.PromptForYesNo("Continue?"))
                    {
                        _consoleUI.WriteWarning($"No subscriptions deleted, exiting.");
                        return Constants.ErrorCode;
                    }
                }

                _consoleUI.Write($"Deleting {subscriptionsToDelete.Count} subscriptions...{(noConfirm ? Environment.NewLine : "")}");
                foreach (var subscription in subscriptionsToDelete)
                {
                    // If noConfirm was passed, print out the subscriptions as we go
                    if (noConfirm)
                    {
                        _consoleUI.WriteLine($"  {UxHelpers.GetSubscriptionDescription(subscription)}");
                    }
                    await _barClient.DeleteSubscriptionAsync(subscription.Id);
                } 
            }
            _consoleUI.WriteSuccess("done");

            return Constants.SuccessCode;
        }
        catch (AuthenticationException e)
        {
            _consoleUI.WriteError(e.Message);
            return Constants.ErrorCode;
        }
        catch (Exception e)
        {
            _consoleUI.WriteError("Unexpected error while deleting subscriptions.");
            _logger.LogError(e, "Unexpected error while deleting subscriptions.");
            return Constants.ErrorCode;
        }
    }
}
