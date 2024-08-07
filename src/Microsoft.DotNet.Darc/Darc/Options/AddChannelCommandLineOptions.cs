// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using CommandLine;
using Microsoft.DotNet.Darc.Operations;

namespace Microsoft.DotNet.Darc.Options;

[Verb("add-channel", HelpText = "Creates a new channel.")]
internal class AddChannelCommandLineOptions : CommandLineOptions<AddChannelOperation>
{
    [Option('n', "name", Required = true, HelpText = "Name of channel to create.")]
    public string Name { get; set; }

    [Option('c', "classification", Default = "dev", HelpText = "Classification of channel. Defaults to 'dev'.")]
    public string Classification { get; set; }

    [Option('i', "internal", HelpText = "Channel is internal only. This option is currently non-functional")]
    public bool Internal { get; set; }

    public override bool IsOutputFormatSupported()
        => OutputFormat switch
        {
            DarcOutputType.json => true,
            _ => base.IsOutputFormatSupported(),
        };
}
