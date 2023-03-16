// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;

#nullable enable
namespace Microsoft.DotNet.DarcLib.VirtualMonoRepo;

public static class ConsoleHelper
{
    public static string PromptUser(string prompt, string? defaultValue = null, bool readCharOnly = false)
    {
        Console.Write($"{prompt}");

        if (defaultValue != null)
        {
            Console.Write(" [");
            WriteColoured($"{defaultValue}", ConsoleColor.Green);
            Console.Write("]");
        }
        Console.Write(": ");
        string? input = readCharOnly ? Console.ReadKey().KeyChar.ToString() : Console.ReadLine();

        if (string.IsNullOrWhiteSpace(input))
        {
            if (defaultValue == null)
            {
                return PromptUser(prompt, defaultValue, readCharOnly);
            }

            input = defaultValue;
        }

        return input.Trim() ?? throw new Exception("Input required");
    }

    public static bool PromptUserYesNo(string prompt, bool defaultValue = true)
    {
        Console.Write($"{prompt} [");
        if (defaultValue)
        {
            WriteColoured("Y", ConsoleColor.Green);
            Console.Write("/n]");
        }
        else
        {
            Console.Write("y/");
            WriteColoured("N", ConsoleColor.Green);
            Console.Write("]");
        }

        Console.Write("? ");

        var input = Console.ReadKey();
        Console.WriteLine();

        if (input.KeyChar == 'y' || input.KeyChar == 'Y')
        {
            return true;
        }
        else if (input.KeyChar == 'n' || input.KeyChar == 'Y')
        {
            return false;
        }
        else if (input.Key == ConsoleKey.Enter || input.Key == ConsoleKey.Spacebar)
        {
            return defaultValue;
        }
        else
        {
            return PromptUserYesNo(prompt, defaultValue);
        }
    }

    public static void WriteColoured(string text, ConsoleColor color)
    {
        var originalColor = Console.ForegroundColor;
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write(text);
        Console.ForegroundColor = originalColor;
    }
}
