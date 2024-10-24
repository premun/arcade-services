﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System.Runtime.Serialization;

#nullable disable
namespace ProductConstructionService.DependencyFlow.WorkItems;

[DataContract]
public class PullRequestCheck : DependencyFlowWorkItem
{
    [DataMember]
    public required string Url { get; set; }
    [DataMember]
    public required bool IsCodeFlow { get; set; }
}
