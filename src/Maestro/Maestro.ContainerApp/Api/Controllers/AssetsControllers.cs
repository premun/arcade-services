// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Net;
using System.Reflection;
using Microsoft.AspNetCore.ApiVersioning.Swashbuckle;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.DotNet.DarcLib;

namespace Maestro.ContainerApp.Api.Controllers;

/// <summary>
///   Exposes methods to Read/Query <see cref="Asset"/>s and modify <see cref="AssetLocation"/> information
/// </summary>
[ApiController]
[Route("assets")]
public class AssetsControllers : Controller
{
    /// <summary>
    ///   Gets the version of Darc in use by this deployment of Maestro.
    /// </summary>
    [HttpGet("darc-version")]
    [SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(string), Description = "Gets the version of darc in use by this Maestro++ instance.")]
    // TODO: check hat this attribute does and if it's needed
    //[ValidateModelState]
    [AllowAnonymous]
    public IActionResult GetDarcVersion()
    {
        // Use the assembly file version, which is the same as the package
        // version. The informational version has a "+<sha>" appended to the end for official builds
        // We don't want this, so eliminate it. The primary use of this is to install the darc version
        // corresponding to the maestro++ version.
        AssemblyInformationalVersionAttribute? informationalVersionAttribute =
            typeof(IRemote).Assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>();
        string? version = informationalVersionAttribute?.InformationalVersion;
        int lastPlus = version?.LastIndexOf('+') ?? -1;
        if (lastPlus != -1)
        {
            version = version?.Substring(0, lastPlus);
        }
        return version is null ? NotFound() : Ok(version);
    }
}
