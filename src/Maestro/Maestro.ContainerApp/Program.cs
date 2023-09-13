// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Maestro.ContainerApp;
using Maestro.Data;
using Microsoft.Extensions.Logging.Console;
using Microsoft.Extensions.Azure;
using StackExchange.Redis;
using Maestro.ContainerApp.Queues;
using Microsoft.EntityFrameworkCore;

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

builder.Services.AddDbContext<BuildAssetRegistryContext>(options =>
{
    var connectionStringSection = Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true"
        ? builder.Configuration.GetSection("ConnectionStrings")
        : builder.Configuration.GetSection("ConnectionStringsNonDocker");

    var connectionString = connectionStringSection["BuildAssetRegistry"];
    if (connectionString != null)
    {
        options.UseSqlServer(connectionString);
    } 
});

builder.Services.AddSingleton<IConnectionMultiplexer>(ConnectionMultiplexer.Connect("host.docker.internal:6379"));

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

