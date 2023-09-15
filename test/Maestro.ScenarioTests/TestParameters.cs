// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using Microsoft.DotNet.Internal.Testing.Utility;
using Microsoft.DotNet.Maestro.Client;
using Microsoft.Extensions.Configuration;
using Octokit;
using Octokit.Internal;

namespace Maestro.ScenarioTests
{
    public class TestParameters : IDisposable
    {
        internal readonly TemporaryDirectory _dir;

        public TestParameters()
        {
        }

        public static async Task<TestParameters> GetAsync()
        {
            TestParameters userSecrets = new ConfigurationBuilder()
                .AddUserSecrets<TestParameters>()
                .Build()
                .Get<TestParameters>();

            string maestroBaseUri = Environment.GetEnvironmentVariable("MAESTRO_BASEURI") ??  userSecrets.MaestroBaseUri ?? "https://maestro-int.westus2.cloudapp.azure.com";
            string maestroToken = Environment.GetEnvironmentVariable("MAESTRO_TOKEN") ?? userSecrets.MaestroToken;
            string githubToken = Environment.GetEnvironmentVariable("GITHUB_TOKEN") ?? userSecrets.GitHubToken;
            string darcPackageSource = Environment.GetEnvironmentVariable("DARC_PACKAGE_SOURCE") ?? userSecrets.DarcPackageSource;
            string azdoToken = Environment.GetEnvironmentVariable("AZDO_TOKEN") ?? userSecrets.AzDoToken;

            var testDir = TemporaryDirectory.Get();
            var testDirSharedWrapper = Shareable.Create(testDir);

            IMaestroApi maestroApi = maestroToken == null
                ? ApiFactory.GetAnonymous(maestroBaseUri)
                : ApiFactory.GetAuthenticated(maestroBaseUri, maestroToken);

            string darcVersion = await maestroApi.Assets.GetDarcVersionAsync();
            string dotnetExe = await TestHelpers.Which("dotnet");

            var toolInstallArgs = new List<string>
            {
                "tool", "install",
                "--tool-path", testDirSharedWrapper.Peek()!.Directory,
                "--version", darcVersion,
                "Microsoft.DotNet.Darc",
            };
            if (!string.IsNullOrEmpty(darcPackageSource))
            {
                toolInstallArgs.Add("--add-source");
                toolInstallArgs.Add(darcPackageSource);
            }
            await TestHelpers.RunExecutableAsync(dotnetExe, toolInstallArgs.ToArray());

            string darcExe = Path.Join(testDirSharedWrapper.Peek()!.Directory, RuntimeInformation.IsOSPlatform(OSPlatform.Windows) ? "darc.exe" : "darc");

            Assembly assembly = typeof(TestParameters).Assembly;
            var githubApi =
                new GitHubClient(
                    new ProductHeaderValue(assembly.GetName().Name, assembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion),
                    new InMemoryCredentialStore(new Credentials(githubToken)));
            var azDoClient =
                new Microsoft.DotNet.DarcLib.AzureDevOpsClient(await TestHelpers.Which("git"), azdoToken, new NUnitLogger(), testDirSharedWrapper.TryTake()!.Directory);

            return new TestParameters(darcExe, await TestHelpers.Which("git"), maestroBaseUri, maestroToken!, githubToken, maestroApi, githubApi, azDoClient, testDir, azdoToken);
        }

        private TestParameters(string darcExePath, string gitExePath, string maestroBaseUri, string maestroToken, string gitHubToken,
            IMaestroApi maestroApi, GitHubClient gitHubApi, Microsoft.DotNet.DarcLib.AzureDevOpsClient azdoClient, TemporaryDirectory dir, string azdoToken)
        {
            _dir = dir;
            DarcExePath = darcExePath;
            GitExePath = gitExePath;
            MaestroBaseUri = maestroBaseUri;
            MaestroToken = maestroToken;
            GitHubToken = gitHubToken;
            MaestroApi = maestroApi;
            GitHubApi = gitHubApi;
            AzDoClient = azdoClient;
            AzDoToken = azdoToken;
        }

        public string DarcPackageSource { get; set; }

        public string DarcExePath { get; set; }

        public string GitExePath { get; set; }

        public string GitHubUser { get; set; } = "dotnet-maestro-bot";

        public string GitHubTestOrg { get; set; } = "maestro-auth-test";

        public string MaestroBaseUri { get; set; }

        public string MaestroToken { get; set; }

        public string GitHubToken { get; set; }

        public IMaestroApi MaestroApi { get; set; }

        public GitHubClient GitHubApi { get; set; }

        public Microsoft.DotNet.DarcLib.AzureDevOpsClient AzDoClient { get; set; }

        public int AzureDevOpsBuildDefinitionId { get; set; } = 6;

        public int AzureDevOpsBuildId { get; set; } = 144618;

        public string AzureDevOpsAccount { get; set; } = "dnceng";

        public string AzureDevOpsProject { get; set; } = "internal";

        public string AzDoToken { get; set; }

        public void Dispose()
        {
            _dir?.Dispose();
        }
    }
}
