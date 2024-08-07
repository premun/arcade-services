// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.DotNet.Internal.DependencyInjection.Testing;
using Microsoft.DotNet.ServiceFabric.ServiceHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using NUnit.Framework;

namespace Maestro.Web.Tests;

[TestFixture]
public class DependencyRegistrationTests
{
    [Test]
    public void AreDependenciesRegistered()
    {
        Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", Environments.Development);

        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string>
            {
                { "EntraAuthentication:UserRole", "Maestro.User" }
            });

        var collection = new ServiceCollection();

        // The only scenario we are worried about is when running in the ServiceHost
        ServiceHost.ConfigureDefaultServices(collection);

        collection.AddSingleton<IConfiguration>(config.Build());
        collection.AddSingleton<Startup>();
        using ServiceProvider provider = collection.BuildServiceProvider();
        var startup = provider.GetRequiredService<Startup>();

        IReadOnlyCollection<Type> controllerTypes = typeof(Startup).Assembly.ExportedTypes
            .Where(t => typeof(ControllerBase).IsAssignableFrom(t)).ToList();

        DependencyInjectionValidation.IsDependencyResolutionCoherent(
            s =>
            {
                foreach (ServiceDescriptor descriptor in collection)
                {
                    s.Add(descriptor);
                }

                startup.ConfigureServices(s);
            },
            out string message,
            additionalScopedTypes: controllerTypes,
            additionalExemptTypes: new[]
            {
                "Microsoft.Identity.Web.Resource.MicrosoftIdentityIssuerValidatorFactory",
                "Maestro.Authentication.BarTokenAuthenticationHandler"
            })

            .Should().BeTrue(message);
    }
}
