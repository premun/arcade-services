// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using Azure.Identity;
using Azure.Storage.Queues;
using Azure.Storage;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Azure;
using NRedisStack;
using StackExchange.Redis;
using System.Text.Json;

namespace Maestro.ContainerApp.Controllers;
[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private readonly ILogger<WeatherForecastController> _logger;
    private readonly QueueServiceClient _queueClient;
    private readonly IConnectionMultiplexer _redis;

    public class Test
    {
        public string Str1 { get; set; } = string.Empty;
        public string Str2 { get; set; } = string.Empty;
        public int Int1 { get; set; } = 0;
        public List<string> List1 { get; set; } = new List<string>();
    }

    public WeatherForecastController(
        ILogger<WeatherForecastController> logger,
        QueueServiceClient queueClient,
        IConnectionMultiplexer redis)
    {
        _logger = logger;
        _queueClient = queueClient;
        _redis = redis;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public async Task<IActionResult> Get()
    {

        var client = await _queueClient.CreateQueueAsync("new-queue");
        IDatabase db = _redis.GetDatabase();
        var req = new Test()
        {
            Int1 = 1,
            Str1 = "2"
        };
        await db.StringSetAsync("foo", JsonSerializer.Serialize(req));
        var a = await db.StringGetAsync("foo");
        var b = JsonSerializer.Deserialize<Test>(a!);
        await client.Value.SendMessageAsync("Hello, Azure!");
        return Ok();
    }
}
