// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.Data;
using Microsoft.AspNetCore.ApiPagination;
using Microsoft.AspNetCore.ApiVersioning;
using Microsoft.AspNetCore.Mvc;
using Microsoft.DotNet.DarcLib;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using Maestro.ContainerApp.Utils;
using Maestro.ContainerApp.Api.Models;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Queues.WorkItems;

namespace Maestro.ContainerApp.Api.Controllers;

/// <summary>
///   Exposes methods to Read/Query/Create <see cref="Build"/>s.
/// </summary>
[ApiController]
[Route("api/builds")]
[ApiVersion("Latest")]
public class BuildsController : ControllerBase
{
    private readonly BuildAssetRegistryContext _dbContext;
    private readonly QueueProducerFactory _queue;
    private readonly IRemoteFactory _remoteFactory;

    public BuildsController(
        BuildAssetRegistryContext context,
        QueueProducerFactory queueClientFactory,
        IRemoteFactory remoteFactory)
    {
        _dbContext = context;
        _queue = queueClientFactory;
        _remoteFactory = remoteFactory;
    }

    /// <summary>
    ///   Gets a paged list of all <see cref="Build"/>s that match the given search criteria.
    /// </summary>
    /// <param name="repository">Repository</param>
    /// <param name="commit">Commit</param>
    /// <param name="buildNumber">Build number</param>
    /// <param name="channelId">Id of the channel to which the build applies</param>
    /// <param name="azdoAccount">Name of the Azure DevOps account</param>
    /// <param name="azdoBuildId">ID of the Azure DevOps build</param>
    /// <param name="azdoProject">Name of the Azure DevOps project</param>
    /// <param name="notBefore">Don't return <see cref="Build"/>s that happened before this time.</param>
    /// <param name="notAfter">Don't return <see cref="Build"/>s that happened after this time.</param>
    /// <param name="loadCollections">**true** to include the <see cref="v2018_07_16.Models.Channel"/>, <see cref="v2018_07_16.Models.Asset"/>, and dependent <see cref="Build"/> data with the response; **false** otherwise.</param>
    [HttpGet]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(List<Build>), Description = "The list of Builds matching the search criteria")]
    [Paginated(typeof(Build))]
    [ValidateModelState]
    public IActionResult ListBuilds(
        string repository,
        string commit,
        string buildNumber,
        int? azdoBuildId,
        string azdoAccount,
        string azdoProject,
        int? channelId,
        DateTimeOffset? notBefore,
        DateTimeOffset? notAfter,
        bool? loadCollections)
    {
        IQueryable<Data.Models.Build> query = Query(
            repository,
            commit,
            buildNumber,
            azdoBuildId,
            azdoAccount,
            azdoProject,
            channelId,
            notBefore,
            notAfter,
            loadCollections);
        return Ok(query);
    }

    /// <summary>
    ///   Gets a single <see cref="Build"/>, including all the <see cref="v2018_07_16.Models.Channel"/>, <see cref="v2018_07_16.Models.Asset"/>, and dependent <see cref="Build"/> data.
    /// </summary>
    /// <param name="id">The id of the <see cref="Build"/>.</param>
    [HttpGet("{id}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Build), Description = "The requested Build")]
    [ValidateModelState]
    public async Task<IActionResult> GetBuild(int id)
    {
        //_logger.LogInformation("# inside");
        Data.Models.Build? build = build = await _dbContext.Builds.Where(b => b.Id == id)
            .Include(b => b.BuildChannels)
            .ThenInclude(bc => bc.Channel)
            .Include(b => b.Assets)
            .FirstOrDefaultAsync();

        if (build == null)
        {
            return NotFound();
        }

        List<Data.Models.BuildDependency> dependentBuilds = _dbContext.BuildDependencies.Where(b => b.BuildId == id).ToList();
        build.DependentBuildIds = dependentBuilds;

        return Ok(new Build(build));
    }

    [HttpGet("{id}/graph")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(BuildGraph), Description = "The tree of build dependencies")]
    [ValidateModelState]
    public async Task<IActionResult> GetBuildGraph(int id)
    {
        Data.Models.Build? build = await _dbContext.Builds.Include(b => b.Incoherencies).FirstOrDefaultAsync(b => b.Id == id);

        if (build == null)
        {
            return NotFound();
        }

        var builds = await _dbContext.GetBuildGraphAsync(build.Id);

        return Ok(BuildGraph.Create(builds.Select(b => new Build(b))));
    }

    /// <summary>
    ///   Gets the latest <see cref="Build"/>s that matches the given search criteria.
    /// </summary>
    /// <param name="repository"></param>
    /// <param name="commit"></param>
    /// <param name="buildNumber"></param>
    /// <param name="channelId"></param>
    /// <param name="notBefore">Don't return <see cref="Build"/>s that happened before this time.</param>
    /// <param name="notAfter">Don't return <see cref="Build"/>s that happened after this time.</param>
    /// <param name="loadCollections">**true** to include the <see cref="v2018_07_16.Models.Channel"/>, <see cref="v2018_07_16.Models.Asset"/>, and dependent <see cref="Build"/> data with the response; **false** otherwise.</param>
    [HttpGet("latest")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Build), Description = "The latest Build matching the search criteria")]
    [ValidateModelState]
    public async Task<IActionResult> GetLatest(
        string repository,
        string commit,
        string buildNumber,
        int? channelId,
        DateTimeOffset? notBefore,
        DateTimeOffset? notAfter,
        bool? loadCollections)
    {
        IQueryable<Data.Models.Build> query = Query(
            repository,
            commit,
            buildNumber,
            null,
            null,
            null,
            channelId,
            notBefore,
            notAfter,
            loadCollections);
        Data.Models.Build? build = await query.OrderByDescending(o => o.DateProduced).FirstOrDefaultAsync();
        if (build == null)
        {
            return NotFound();
        }

        return Ok(new Models.Build(build));
    }

    [HttpGet("{buildId}/commit")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Models.Commit), Description = "The commit matching specified criteria")]
    [ValidateModelState]
    public async Task<IActionResult> GetCommit(int buildId)
    {
        Data.Models.Build? build = await _dbContext.Builds.Include(b => b.Incoherencies).FirstOrDefaultAsync(b => b.Id == buildId);
        if (build == null)
        {
            return NotFound();
        }

        IRemote remote = await _remoteFactory.GetRemoteAsync(build.AzureDevOpsRepository ?? build.GitHubRepository, null);
        Microsoft.DotNet.DarcLib.Commit commit = await remote.GetCommitAsync(build.AzureDevOpsRepository ?? build.GitHubRepository, build.Commit);
        return Ok(new Models.Commit(commit.Author, commit.Sha, commit.Message));
    }

    [HttpPatch("{buildId}")]
    //[SwaggerApiResponse(HttpStatusCode.OK, Type = typeof(Build), Description = "Update a build with new information.")]
    [ValidateModelState]
    public virtual async Task<IActionResult> Update(int buildId, [FromBody, Required] BuildUpdate buildUpdate)
    {
        Data.Models.Build? build = await _dbContext.Builds.Where(b => b.Id == buildId).FirstOrDefaultAsync();

        if (build == null)
        {
            return NotFound();
        }

        bool doUpdate = false;
        if (buildUpdate.Released.HasValue && build.Released != buildUpdate.Released.Value)
        {
            build.Released = buildUpdate.Released.Value;
            doUpdate = true;
        }

        if (doUpdate)
        {
            _dbContext.Builds.Update(build);
            await _dbContext.SaveChangesAsync();
        }

        return Ok(new Build(build));
    }

    /// <summary>
    ///   Creates a new <see cref="Build"/> in the database.
    /// </summary>
    /// <param name="build">An object containing the data for the new <see cref="Build"/></param>
    [HttpPost]
    //[SwaggerApiResponse(HttpStatusCode.Created, Type = typeof(Build), Description = "The created build")]
    [ValidateModelState]
    public async Task<IActionResult> Create([FromBody, Required] BuildData build)
    {
        Data.Models.Build buildModel = build.ToDb();
        buildModel.DateProduced = DateTimeOffset.UtcNow;

        if (build.Dependencies != null)
        {
            // For each Dependency, update the time to Inclusion.
            // This measure is to be used for telemetry purposes, and has several known corner cases
            // where the measurement will not be correct:
            // 1. For any dependencies that were added before this column was added, the TimeToInclusionInMinutes
            //    will be 0.
            // 2. For new release branches, until new builds of dependencies are added, this will recalculate
            //    the TimeToInclusion, so it will seem inordinately large until new builds are added. This will
            //    be particularly true for dependencies that are infrequently updated.
            foreach (var dep in build.Dependencies)
            {
                // Heuristic to discover if this dependency has been added to the same repository and branch 
                // of the current build. If we find a match in the BuildDependencies table, it means
                // that this is not a new dependency, and we should use the TimeToInclusionInMinutes
                // of the previous time this dependency was added.
                var buildDependency = await _dbContext.BuildDependencies.FirstOrDefaultAsync(d =>
                    d.DependentBuildId == dep.BuildId &&
                    d.Build.GitHubRepository == buildModel.GitHubRepository &&
                    d.Build.GitHubBranch == buildModel.GitHubBranch &&
                    d.Build.AzureDevOpsRepository == buildModel.AzureDevOpsRepository &&
                    d.Build.AzureDevOpsBranch == buildModel.AzureDevOpsBranch
                );

                if (buildDependency != null)
                {
                    dep.TimeToInclusionInMinutes = buildDependency.TimeToInclusionInMinutes;
                }
                else
                {
                    // If the dependent build is not currently in the BuildDependency table for this repo/branch (ie is a new dependency),
                    // find the dependency in the Builds table and calculate the time to inclusion

                    // We want to use the BuildChannel insert time if it exists. So we need to heuristically:
                    // 1. Find the subscription between these two repositories on the current branch
                    // 2. Find the entry in BuildChannels and get the insert time
                    // In certain corner cases, we may pick the wrong subscription or BuildChannel

                    Data.Models.Build? depBuild = await _dbContext.Builds.FindAsync(dep.BuildId);
                    if (depBuild is null) throw new Exception("TODO: this must be improved");

                    // If we don't find a subscription or a BuildChannel entry, use the dependency's
                    // date produced.
                    DateTimeOffset startTime = depBuild.DateProduced;

                    Data.Models.Subscription? subscription = await _dbContext.Subscriptions.FirstOrDefaultAsync(s =>
                        (s.SourceRepository == depBuild.GitHubRepository ||
                         s.SourceRepository == depBuild.AzureDevOpsRepository) &&
                        (s.TargetRepository == buildModel.GitHubRepository ||
                         s.TargetRepository == buildModel.AzureDevOpsRepository) &&
                        (s.TargetBranch == buildModel.GitHubBranch ||
                         s.TargetBranch == buildModel.AzureDevOpsBranch));


                    if (subscription != null)
                    {
                        Data.Models.BuildChannel? buildChannel = await _dbContext.BuildChannels.FirstOrDefaultAsync(bc =>
                            bc.BuildId == depBuild.Id &&
                            bc.ChannelId == subscription.ChannelId
                        );

                        if (buildChannel != null)
                        {
                            startTime = buildChannel.DateTimeAdded;
                        }
                    }

                    dep.TimeToInclusionInMinutes = (buildModel.DateProduced - startTime).TotalMinutes;
                }
            }

            await _dbContext.BuildDependencies.AddRangeAsync(
                build.Dependencies.Select(
                    b => new Data.Models.BuildDependency
                    {
                        Build = buildModel,
                        DependentBuildId = b.BuildId,
                        IsProduct = b.IsProduct,
                        TimeToInclusionInMinutes = b.TimeToInclusionInMinutes,
                    }));
        }

        await _dbContext.Builds.AddAsync(buildModel);
        await _dbContext.SaveChangesAsync();

        // Compute the dependency incoherencies of the build.
        // Since this might be an expensive operation we do it asynchronously.
        var queueClient = _queue.Create<BuildCoherencyInfoWorkItem>();
        await queueClient.SendAsync(new BuildCoherencyInfoWorkItem
        {
            BuildId = buildModel.Id
        });

        return CreatedAtRoute(
            new
            {
                action = "GetBuild",
                id = buildModel.Id
            },
            new Build(buildModel));
    }

    protected IQueryable<Data.Models.Build> Query(
        string repository,
        string commit,
        string buildNumber,
        int? azdoBuildId,
        string? azdoAccount,
        string? azdoProject,
        int? channelId,
        DateTimeOffset? notBefore,
        DateTimeOffset? notAfter,
        bool? loadCollections)
    {
        IQueryable<Data.Models.Build> query = _dbContext.Builds;
        if (!string.IsNullOrEmpty(repository))
        {
            query = query.Where(b => (repository == b.GitHubRepository || repository == b.AzureDevOpsRepository));
        }

        if (!string.IsNullOrEmpty(commit))
        {
            query = query.Where(b => b.Commit == commit);
        }

        if (!string.IsNullOrEmpty(buildNumber))
        {
            query = query.Where(b => b.AzureDevOpsBuildNumber == buildNumber);
        }

        if (azdoBuildId.HasValue)
        {
            query = query.Where(b => b.AzureDevOpsBuildId == azdoBuildId);
        }

        if (!string.IsNullOrEmpty(azdoAccount))
        {
            query = query.Where(b => b.AzureDevOpsAccount == azdoAccount);
        }

        if (!string.IsNullOrEmpty(azdoProject))
        {
            query = query.Where(b => b.AzureDevOpsProject == azdoProject);
        }

        if (notBefore.HasValue)
        {
            query = query.Where(b => b.DateProduced >= notBefore.Value);
        }

        if (notAfter.HasValue)
        {
            query = query.Where(b => b.DateProduced <= notAfter.Value);
        }

        if (channelId.HasValue)
        {
            query = query.Where(b => b.BuildChannels.Any(c => c.ChannelId == channelId.Value));
        }

        if (loadCollections ?? false)
        {
            query = query
                .Include(b => b.BuildChannels)
                .ThenInclude(bc => bc.Channel)
                .Include(b => b.Assets);
        }

        return query.OrderByDescending(b => b.DateProduced);
    }
}
