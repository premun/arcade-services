﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.ComponentModel.DataAnnotations;
using System.Net;
using Maestro.ContainerApp.Api.Models;
using Maestro.ContainerApp.Utils;
using Microsoft.AspNetCore.ApiVersioning;
using Microsoft.AspNetCore.Mvc;

namespace Maestro.ContainerApp.Api.Controllers;

/// <summary>
///   Exposes methods to Create/Read/Delete <see cref="ReleasePipeline"/> information.
/// </summary>
[Route("pipelines")]
[ApiVersion("Latest")]
public class PipelinesController : Controller
{
    /// <summary>
    ///   Gets a list of all <see cref="ReleasePipeline"/>s that match the given search criteria.
    /// </summary>
    /// <param name="pipelineIdentifier">The Azure DevOps Release Pipeline id</param>
    /// <param name="organization">The Azure DevOps organization</param>
    /// <param name="project">The Azure DevOps project</param>
    [HttpGet]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(List<ReleasePipeline>), Description = "The list of ReleasePipelines")]
    [ValidateModelState]
    public IActionResult List(int? pipelineIdentifier = null, string? organization = null, string? project = null)
    {
        return Ok(new List<ReleasePipeline>());
    }

    /// <summary>
    ///   Gets a single <see cref="ReleasePipeline"/>.
    /// </summary>
    /// <param name="id">The id of the <see cref="ReleasePipeline"/> to get</param>
    [HttpGet("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(ReleasePipeline), Description = "The requested ReleasePipeline")]
    [ValidateModelState]
    public Task<IActionResult> GetPipeline(int id)
    {
        return Task.FromResult<IActionResult>(NotFound());
    }

    /// <summary>
    ///   Deletes a <see cref="ReleasePipeline"/>
    /// </summary>
    /// <param name="id">The id of the <see cref="ReleasePipeline"/> to delete</param>
    [HttpDelete("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(ReleasePipeline), Description = "ReleasePipeline successfully deleted")]
    [ValidateModelState]
    public Task<IActionResult> DeletePipeline(int id)
    {
        return Task.FromResult<IActionResult>(StatusCode((int)HttpStatusCode.NotModified));
    }

    /// <summary>
    ///   Creates a <see cref="ReleasePipeline"/>
    /// </summary>
    /// <param name="pipelineIdentifier">The Azure DevOps Release Pipeline id</param>
    /// <param name="organization">The Azure DevOps organization</param>
    /// <param name="project">The Azure DevOps project</param>
    [HttpPost]
    //[SwaggerApiResponse(HttpStatusCode.Created, Type = typeof(ReleasePipeline), Description = "ReleasePipeline successfully created")]
    public Task<IActionResult> CreatePipeline([Required] int pipelineIdentifier, [Required] string organization, [Required] string project)
    {
        return Task.FromResult<IActionResult>(StatusCode((int)HttpStatusCode.NotModified));
    }
}
