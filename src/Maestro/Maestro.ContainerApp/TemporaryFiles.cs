// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

namespace Maestro.ContainerApp;

public class TemporaryFiles : IDisposable
{
    private readonly ILogger<TemporaryFiles> _logger;

    private readonly string _isolatedTempPath;

    public TemporaryFiles(ILogger<TemporaryFiles> logger)
    {
        _logger = logger;
        _isolatedTempPath = Path.Combine(Path.GetTempPath(), "hackathon", Guid.NewGuid().ToString());
    }

    public void Initialize()
    {
        Cleanup();
        _logger.LogTrace("Creating isolated temp directory at {path}", _isolatedTempPath);
        Directory.CreateDirectory(_isolatedTempPath);
    }

    public string GetFilePath(params string[] parts)
    {
        return Path.Combine(_isolatedTempPath, Path.Combine(parts));
    }

    public void Dispose()
    {
        Cleanup();
    }

    private void Cleanup()
    {
        try
        {
            if (Directory.Exists(_isolatedTempPath))
            {
                _logger.LogTrace("Temporary files found, cleaning up {path}", _isolatedTempPath);
                Directory.Delete(_isolatedTempPath, recursive: true);
            }
        }
        catch (IOException exception)
        {
            _logger.LogError(exception, "Failed to clean up temporary directory {path}", _isolatedTempPath);
        }
    }
}
