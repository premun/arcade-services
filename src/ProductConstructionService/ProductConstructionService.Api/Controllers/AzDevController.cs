// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Microsoft.AspNetCore.Mvc;
using Microsoft.DotNet.DarcLib;

namespace ProductConstructionService.Api.Controllers;

[Route("[controller]")]
[Route("_/[controller]")]
public class AzDevController(IAzureDevOpsClientFactory azureDevOpsClientFactory)
    : ControllerBase
{
    [HttpGet("build/status/{account}/{project}/{definitionId}/{*branch}")]
    public async Task<IActionResult> GetBuildStatus(string account, string project, int definitionId, string? branch, int count, string status)
    {
        var azdoClient = azureDevOpsClientFactory.CreateAzureDevOpsClient(account, project);
        var builds = await azdoClient.GetBuildsAsync(definitionId, branch, count, status);
        return Ok(builds);
    }
}
