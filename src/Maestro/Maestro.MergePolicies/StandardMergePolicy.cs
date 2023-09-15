// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Contracts;
using Maestro.MergePolicyEvaluation;
using System;
using System.Collections.Generic;
using System.Text.Json.Nodes;
using System.Threading.Tasks;

namespace Maestro.MergePolicies;

public class StandardMergePolicyBuilder : IMergePolicyBuilder
{
    private static readonly MergePolicyProperties s_standardGitHubProperties;
    private static readonly MergePolicyProperties s_standardAzureDevOpsProperties;

    public string Name => MergePolicyConstants.StandardMergePolicyName;

    static StandardMergePolicyBuilder()
    {
        s_standardGitHubProperties = new MergePolicyProperties(new Dictionary<string, JsonNode>
        {
            { 
                MergePolicyConstants.IgnoreChecksMergePolicyPropertyName, 
                new JsonArray(
                    "WIP",
                    "license/cla",
                    "auto-merge.config.enforce",
                    "Build Analysis"
                )
            },
        });

        s_standardAzureDevOpsProperties = new MergePolicyProperties(new Dictionary<string, JsonNode>
        {
            {
                MergePolicyConstants.IgnoreChecksMergePolicyPropertyName,
                new JsonArray(
                    "Comment requirements",
                    "Minimum number of reviewers",
                    "auto-merge.config.enforce",
                    "Work item linking"
                )
            },
        });
    }

    public async Task<IReadOnlyList<IMergePolicy>> BuildMergePoliciesAsync(MergePolicyProperties properties, IPullRequest pr)
    {
        string prUrl = pr.Url;
        MergePolicyProperties standardProperties;
        if (prUrl.Contains("github.com"))
        {
            standardProperties = s_standardGitHubProperties;
        }
        else if (prUrl.Contains("dev.azure.com"))
        {
            standardProperties = s_standardAzureDevOpsProperties;
        }
        else
        {
            throw new NotImplementedException("Unknown pr repo url");
        }

        var policies = new List<IMergePolicy>();
        policies.AddRange(await new AllChecksSuccessfulMergePolicyBuilder().BuildMergePoliciesAsync(standardProperties, pr));
        policies.AddRange(await new NoRequestedChangesMergePolicyBuilder().BuildMergePoliciesAsync(standardProperties, pr));
        policies.AddRange(await new DontAutomergeDowngradesMergePolicyBuilder().BuildMergePoliciesAsync(standardProperties, pr));
        return policies;
    }
}
