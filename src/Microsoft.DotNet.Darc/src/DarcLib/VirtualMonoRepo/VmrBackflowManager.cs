// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System.Threading.Tasks;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public interface IVmrBackflowManager
{
    Task BackflowAsync();
}

public class VmrBackflowManager : IVmrBackflowManager
{
    public Task BackflowAsync()
    {
        throw new System.NotImplementedException();
    }
}
