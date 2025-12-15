// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

using System;
using System.Linq;
using System.Collections.Generic;

namespace Maestro.DataProviders.ConfigurationIngestion.Validations;

internal class EntityValidator
{
    internal static void ValidateEntityUniqueness<T, TId>(IEnumerable<T> entities, Func<T, TId> idSelector)
        where T : class
        where TId : notnull
    {
        if (!entities.Any())
        {
            return;
        }

        var uniqueIds = entities.Select(idSelector).ToHashSet();

        if (uniqueIds.Count != entities.Count())
        {
            throw new ArgumentException($"{entities.GetType().GetGenericArguments()[0].Name} collection "
            + "contains duplicate Ids.");
        }
    }
}
