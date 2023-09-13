// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp;
using Maestro.ContainerApp.Actors;
using Maestro.ContainerApp.Api.Controllers;
using Maestro.ContainerApp.Queues;
using Maestro.ContainerApp.Utils;
using Maestro.Data;
using Microsoft.DotNet.GitHub.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Console;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddLogging(b =>
    b.AddConsole(options =>
        options.FormatterName = SimpleConsoleLoggerFormatter.FormatterName)
     .AddConsoleFormatter<SimpleConsoleLoggerFormatter, SimpleConsoleFormatterOptions>(
        options => options.TimestampFormat = "[HH:mm:ss] "));

builder.AddBackgroudQueueProcessors();
builder.AddActors();
builder.AddControllerConfigurations();

builder.Services.AddDbContext<BuildAssetRegistryContext>(options =>
{
    options.UseSqlServer(builder.GetConnectionString("BuildAssetRegistry"));
});
builder.Services.AddSingleton<IInstallationLookup, BuildAssetRegistryInstallationLookup>();

// singleton services
builder.Services.AddSingleton<IConnectionMultiplexer>(ConnectionMultiplexer.Connect(builder.GetConnectionString("Redis")));
builder.Services.AddSingleton<TemporaryFiles>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();

