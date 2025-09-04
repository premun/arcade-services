// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Collections.Immutable;
using Maestro.Data.Models;
using Maestro.MergePolicies;
using Maestro.MergePolicyEvaluation;
using Microsoft.DotNet.DarcLib;
using Microsoft.Extensions.Logging;

namespace ProductConstructionService.DependencyFlow;

internal interface IMergePolicyEvaluator
{
    Task<IReadOnlyCollection<MergePolicyEvaluationResult>> EvaluateAsync(
        PullRequestUpdateSummary pr,
        IRemote darc,
        IReadOnlyList<MergePolicyDefinition> policyDefinitions,
        MergePolicyEvaluationResults? cachedResults,
        string targetBranchSha);
}

internal class MergePolicyEvaluator : IMergePolicyEvaluator
{
    private readonly ImmutableDictionary<string, IMergePolicyBuilder> _mergePolicyBuilders;
    private readonly ILogger<MergePolicyEvaluator> _logger;

    public MergePolicyEvaluator(
        IEnumerable<IMergePolicyBuilder> mergePolicies,
        ILogger<MergePolicyEvaluator> logger)
    {
        _mergePolicyBuilders = mergePolicies.ToImmutableDictionary(p => p.Name);
        _logger = logger;
    }

    public async Task<IReadOnlyCollection<MergePolicyEvaluationResult>> EvaluateAsync(
        PullRequestUpdateSummary pr,
        IRemote darc,
        IReadOnlyList<MergePolicyDefinition> policyDefinitions,
        MergePolicyEvaluationResults? cachedResults,
        string targetBranchSha)
    {
        Dictionary<string, MergePolicyEvaluationResult> resultsByPolicyName = [];
        Dictionary<string, MergePolicyEvaluationResult> cachedResultsByPolicyName =
            cachedResults?.Results.ToDictionary(r => r.MergePolicyName, r => r) ?? [];

        foreach (MergePolicyDefinition definition in policyDefinitions)
        {
            if (!_mergePolicyBuilders.TryGetValue(definition.Name, out IMergePolicyBuilder? policyBuilder))
            {
                var notImplemented = new NotImplementedMergePolicy(definition.Name);
                resultsByPolicyName[definition.Name] = new MergePolicyEvaluationResult(
                    MergePolicyEvaluationStatus.DecisiveFailure,
                    $"Unknown Merge Policy: '{definition.Name}'",
                    string.Empty,
                    string.Empty,
                    notImplemented.DisplayName);
                continue;
            }

            var policies = await policyBuilder.BuildMergePoliciesAsync(new MergePolicyProperties(definition.Properties), pr);
            foreach (var policy in policies)
            {
                if (cachedResultsByPolicyName.TryGetValue(policy.Name, out var cachedEvaluationResult) &&
                    CanSkipRerunningPRCheck(cachedResults?.TargetCommitSha, cachedEvaluationResult, targetBranchSha))
                {
                    _logger.LogInformation("Skipping re-evaluation of {policyName}, which has result {policyResult} at commitSha {commitSha}",
                        policy.Name, cachedEvaluationResult.Status, cachedResults?.TargetCommitSha);
                    cachedEvaluationResult.IsCachedResult = true;
                    resultsByPolicyName[policy.Name] = cachedEvaluationResult;
                }
                else
                {
                    resultsByPolicyName[policy.Name] = await policy.EvaluateAsync(pr, darc);
                }
            }
        }
        return resultsByPolicyName.Values;
    }

    private static bool CanSkipRerunningPRCheck(
        string? cachedCommitSha,
        MergePolicyEvaluationResult? cachedEvaluationValue,
        string targetBranchSha)
    {
        if (cachedCommitSha == null || !cachedCommitSha.Equals(targetBranchSha))
        {
            return false;
        }
        return cachedEvaluationValue?.Status is MergePolicyEvaluationStatus.DecisiveFailure or MergePolicyEvaluationStatus.DecisiveSuccess;
    }

    private class NotImplementedMergePolicy : MergePolicy
    {
        private readonly string _definitionName;

        public override string Name => "NotImplemented";

        public NotImplementedMergePolicy(string definitionName)
        {
            _definitionName = definitionName;
        }

        public override string DisplayName => $"Not implemented merge policy '{_definitionName}'";

        public override Task<MergePolicyEvaluationResult> EvaluateAsync(PullRequestUpdateSummary pr, IRemote darc)
        {
            throw new NotImplementedException();
        }
    }
}
