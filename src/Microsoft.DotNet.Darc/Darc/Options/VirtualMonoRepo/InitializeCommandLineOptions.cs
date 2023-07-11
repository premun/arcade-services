// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using CommandLine;
using Microsoft.DotNet.Darc.Operations;
using Microsoft.DotNet.Darc.Operations.VirtualMonoRepo;
using Microsoft.DotNet.DarcLib.VirtualMonoRepo;

namespace Microsoft.DotNet.Darc.Options.VirtualMonoRepo;

[Verb("initialize", HelpText = "Initializes new repo(s) that haven't been synchronized into the VMR yet.")]
internal class InitializeCommandLineOptions : VmrSyncCommandLineOptions
{
    [Option("source-mappings", Required = true, HelpText = $"A path to the {VmrInfo.SourceMappingsFileName} file to be used for syncing.")]
    public string SourceMappings { get; set; }

    public override Operation GetOperation() => new InitializeOperation(this);
}
