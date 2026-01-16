#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Determines which repositories a VMR build has back-flowed to.

.DESCRIPTION
    This script analyzes a VMR build to determine which repositories it has back-flowed to
    by checking backflow subscriptions and comparing build versions.
    
    For internal release branches, it also looks up the corresponding public release branch
    to show both internal and public backflow status.

.PARAMETER VmrPath
    Path to the local clone of the VMR (.NET repo).

.PARAMETER BuildId
    The Build ID to analyze for backflow status.

.EXAMPLE
    .\Get-BackflowStatus.ps1 -VmrPath "C:\repos\dotnet" -BuildId 12345
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VmrPath,

    [Parameter(Mandatory = $true)]
    [int]$BuildId
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$ForegroundColor = "White"
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Get-BuildInfo {
    param([int]$BuildId)

    Write-ColorOutput "Fetching build information for Build ID: $BuildId..." -ForegroundColor Cyan

    try {
        $buildJson = darc get-build --id $BuildId --output-format json | ConvertFrom-Json
        return $buildJson
    }
    catch {
        Write-ColorOutput "Error: Failed to get build information for Build ID $BuildId" -ForegroundColor Red
        Write-ColorOutput $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

function Get-BuildChannel {
    param($BuildInfo)

    if ($BuildInfo.channels -and $BuildInfo.channels.Count -gt 0) {
        return $BuildInfo.channels[0]
    }

    Write-ColorOutput "Warning: Build is not assigned to any channel" -ForegroundColor Yellow
    return $null
}

function Test-IsInternalBranch {
    param([string]$Branch)
    
    return $Branch -match "internal/"
}

function Get-PublicBranchFromInternal {
    param([string]$InternalBranch)
    
    # Convert "internal/release/X.Y" to "release/X.Y"
    if ($InternalBranch -match "^internal/(.+)$") {
        return $matches[1]
    }
    
    return $null
}

function Get-PublicChannelFromInternal {
    param([string]$InternalChannel)
    
    # Internal channels typically have "-internal" suffix or similar pattern
    # Try to derive the public channel name
    if ($InternalChannel -match "^(.+)-internal$") {
        return $matches[1]
    }
    
    # If channel contains "Internal", try removing it
    if ($InternalChannel -match "Internal") {
        return $InternalChannel -replace "\s*Internal\s*", " " -replace "\s+", " " -replace "^\s+|\s+$", ""
    }
    
    return $null
}

function Get-LatestBuildForChannel {
    param(
        [string]$Repository,
        [string]$Channel,
        [string]$Branch
    )
    
    Write-ColorOutput "Looking up latest build for $Repository on branch $Branch in channel $Channel..." -ForegroundColor Cyan
    
    try {
        $builds = darc get-builds --repo $Repository --channel "$Channel" --output-format json 2>$null | ConvertFrom-Json
        
        if ($builds -and $builds.Count -gt 0) {
            # Filter by branch if specified and find the latest
            $filteredBuilds = if ($Branch) {
                $builds | Where-Object { $_.branch -eq $Branch -or $_.branch -eq "refs/heads/$Branch" }
            } else {
                $builds
            }
            
            if ($filteredBuilds -and $filteredBuilds.Count -gt 0) {
                # Return the first (most recent) build
                return $filteredBuilds | Select-Object -First 1
            }
        }
        
        return $null
    }
    catch {
        Write-ColorOutput "Warning: Could not fetch builds for channel $Channel" -ForegroundColor Yellow
        return $null
    }
}

function Get-BackflowSubscriptions {
    param($BuildInfo, [string]$ChannelName)

    Write-ColorOutput "`nFetching backflow subscriptions for channel: $ChannelName..." -ForegroundColor Cyan

    try {
        return darc get-subscriptions --channel "$ChannelName" --exact --source-repo "$($BuildInfo.repository)" --source-enabled true --output-format json | ConvertFrom-Json
    }
    catch {
        Write-ColorOutput "Error: Failed to get subscriptions for channel $ChannelName" -ForegroundColor Red
        Write-ColorOutput $_.Exception.Message -ForegroundColor Red
        return @()
    }
}

function Test-CommitIsAncestor {
    param(
        [string]$VmrPath,
        [string]$AncestorCommit,
        [string]$DescendantCommit
    )

    try {
        # Use git merge-base to check if ancestor commit is in the history of descendant
        $mergeBase = git -C $VmrPath merge-base $AncestorCommit $DescendantCommit 2>$null

        if ($LASTEXITCODE -ne 0) {
            return $null  # Unable to determine
        }

        # If merge-base equals ancestor, then ancestor is in the history
        return $mergeBase -eq $AncestorCommit
    }
    catch {
        return $null
    }
}

function Get-CommitDistance {
    param(
        [string]$VmrPath,
        [string]$FromCommit,
        [string]$ToCommit
    )
    
    try {
        $count = git -C $VmrPath rev-list --count "$FromCommit..$ToCommit" 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $count -match '^\d+$') {
            return [int]$count
        }
        
        return $null
    }
    catch {
        return $null
    }
}

function Get-StatusSymbol {
    param([string]$Status)

    switch ($Status) {
        "Current" { return "✅" }
        "Newer" { return "✅" }
        "Older" { return "❌" }
        "Unknown" { return "❓" }
        "N/A" { return "➖" }
        default { return "❓" }
    }
}

function Get-SimplifiedRepoName {
    param([string]$RepoUrl)

    if ($RepoUrl -match 'github\.com/([^/]+/[^/]+?)(?:\.git)?$') {
        return $matches[1]
    }
    elseif ($RepoUrl -match 'dev\.azure\.com/[^/]+/[^/]+/_git/(.+)$') {
        return $matches[1]
    }

    # Return as-is if pattern doesn't match
    return $RepoUrl
}

function Get-BackflowStatusForBuild {
    param(
        [string]$VmrPath,
        $BuildInfo,
        [string]$CurrentCommit,
        $Subscriptions,
        [string]$BuildLabel
    )
    
    $results = @()
    
    foreach ($subscription in $Subscriptions) {
        $lastAppliedBuild = $subscription.lastAppliedBuild

        if (-not $lastAppliedBuild) {
            $results += [PSCustomObject]@{
                BuildLabel = $BuildLabel
                SubscriptionId = $subscription.id
                TargetRepo = $subscription.targetRepository
                TargetBranch = $subscription.targetBranch
                LastAppliedBuild = "None"
                Status = "Unknown"
                Details = "No builds have been applied yet"
            }
            continue
        }

        # Compare build IDs
        if ($lastAppliedBuild.id -eq $BuildInfo.id) {
            $results += [PSCustomObject]@{
                BuildLabel = $BuildLabel
                SubscriptionId = $subscription.id
                TargetRepo = $subscription.targetRepository
                TargetBranch = $subscription.targetBranch
                LastAppliedBuild = $lastAppliedBuild.id
                Status = "Current"
                Details = "Current"
            }
        }
        elseif ($lastAppliedBuild.id -gt $BuildInfo.id) {
            $results += [PSCustomObject]@{
                BuildLabel = $BuildLabel
                SubscriptionId = $subscription.id
                TargetRepo = $subscription.targetRepository
                TargetBranch = $subscription.targetBranch
                LastAppliedBuild = $lastAppliedBuild.id
                Status = "Newer"
                Details = "Newer ($($lastAppliedBuild.id))"
            }
        }
        else {
            # Need to check if the commit is an ancestor
            $lastAppliedCommit = $lastAppliedBuild.commit

            if ($lastAppliedCommit) {
                $isAncestor = Test-CommitIsAncestor -VmrPath $VmrPath -AncestorCommit $lastAppliedCommit -DescendantCommit $CurrentCommit

                if ($null -eq $isAncestor) {
                    $results += [PSCustomObject]@{
                        BuildLabel = $BuildLabel
                        SubscriptionId = $subscription.id
                        TargetRepo = $subscription.targetRepository
                        TargetBranch = $subscription.targetBranch
                        LastAppliedBuild = $lastAppliedBuild.id
                        Status = "Unknown"
                        Details = "Build from a different branch flown"
                    }
                }
                elseif ($isAncestor) {
                    $commitDistance = Get-CommitDistance -VmrPath $VmrPath -FromCommit $lastAppliedCommit -ToCommit $CurrentCommit
                    
                    if ($commitDistance) {
                        # Apply color based on distance thresholds
                        $distanceColor = if ($commitDistance -gt 20) { 
                            "`e[91m" # Red
                        } elseif ($commitDistance -gt 10) { 
                            "`e[93m" # Yellow
                        } else { 
                            "`e[0m" # White/Reset
                        }
                        $distanceText = "$distanceColor$commitDistance commits behind`e[0m"
                    } else {
                        $distanceText = "behind"
                    }
                    
                    $results += [PSCustomObject]@{
                        BuildLabel = $BuildLabel
                        SubscriptionId = $subscription.id
                        TargetRepo = $subscription.targetRepository
                        TargetBranch = $subscription.targetBranch
                        LastAppliedBuild = $lastAppliedBuild.id
                        Status = "Older"
                        Details = "Older ($($lastAppliedBuild.id), $distanceText)"
                    }
                }
                else {
                    $results += [PSCustomObject]@{
                        BuildLabel = $BuildLabel
                        SubscriptionId = $subscription.id
                        TargetRepo = $subscription.targetRepository
                        TargetBranch = $subscription.targetBranch
                        LastAppliedBuild = $lastAppliedBuild.id
                        Status = "Newer"
                        Details = "Newer ($($lastAppliedBuild.id))"
                    }
                }
            }
            else {
                $results += [PSCustomObject]@{
                    BuildLabel = $BuildLabel
                    SubscriptionId = $subscription.id
                    TargetRepo = $subscription.targetRepository
                    TargetBranch = $subscription.targetBranch
                    LastAppliedBuild = $lastAppliedBuild.id
                    Status = "Unknown"
                    Details = "Could not retrieve commit information"
                }
            }
        }
    }
    
    return $results
}

# Main script execution
Write-ColorOutput "=== VMR Backflow Analysis ===" -ForegroundColor Green
Write-ColorOutput "VMR Path: $VmrPath"
Write-ColorOutput "Build ID: $BuildId"
Write-ColorOutput ""

# Validate VMR path
if (-not (Test-Path $VmrPath)) {
    Write-ColorOutput "Error: VMR path does not exist: $VmrPath" -ForegroundColor Red
    exit 1
}

# Step 1: Get build information
$buildInfo = Get-BuildInfo -BuildId $BuildId
$currentCommit = $buildInfo.commit
$branch = $buildInfo.branch -replace "^refs/heads/", ""

Write-ColorOutput "Build Commit: $currentCommit" -ForegroundColor White
Write-ColorOutput "Build Repository: $($buildInfo.repository)" -ForegroundColor White
Write-ColorOutput "Build Branch: $branch" -ForegroundColor White

# Step 2: Determine the channel
$channel = Get-BuildChannel -BuildInfo $buildInfo

if (-not $channel) {
    Write-ColorOutput "Cannot proceed without a channel assignment." -ForegroundColor Red
    exit 1
}

Write-ColorOutput "Build Channel: $channel" -ForegroundColor White

# Step 3: Check if this is an internal build
$isInternalBuild = Test-IsInternalBranch -Branch $branch
$publicBuildInfo = $null
$publicChannel = $null

if ($isInternalBuild) {
    Write-ColorOutput "`nDetected internal release branch - looking for corresponding public build..." -ForegroundColor Yellow
    
    $publicBranch = Get-PublicBranchFromInternal -InternalBranch $branch
    $publicChannel = Get-PublicChannelFromInternal -InternalChannel $channel
    
    if ($publicBranch -and $publicChannel) {
        Write-ColorOutput "Public branch: $publicBranch" -ForegroundColor White
        Write-ColorOutput "Public channel: $publicChannel" -ForegroundColor White
        
        $publicBuildInfo = Get-LatestBuildForChannel -Repository $buildInfo.repository -Channel $publicChannel -Branch $publicBranch
        
        if ($publicBuildInfo) {
            Write-ColorOutput "Found public build: $($publicBuildInfo.id) (commit: $($publicBuildInfo.commit))" -ForegroundColor Green
        }
        else {
            Write-ColorOutput "Could not find a public build for branch $publicBranch in channel $publicChannel" -ForegroundColor Yellow
        }
    }
    else {
        Write-ColorOutput "Could not determine public branch/channel from internal: $branch / $channel" -ForegroundColor Yellow
    }
}

# Step 4: Get backflow subscriptions for primary (internal) build
$backflowSubscriptions = Get-BackflowSubscriptions -BuildInfo $buildInfo -ChannelName "$channel"

if ($backflowSubscriptions.Count -eq 0) {
    Write-ColorOutput "`nNo backflow subscriptions found for channel: $channel" -ForegroundColor Yellow
    exit 0
}

Write-ColorOutput "`nFound $($backflowSubscriptions.Count) backflow subscription(s) for primary build`n" -ForegroundColor Green

# Step 5: Get backflow status for primary build
$buildLabel = if ($isInternalBuild) { "Internal" } else { "Primary" }
$allResults = Get-BackflowStatusForBuild -VmrPath $VmrPath -BuildInfo $buildInfo -CurrentCommit $currentCommit -Subscriptions $backflowSubscriptions -BuildLabel $buildLabel

# Step 6: If we have a public build, get its backflow status too
if ($publicBuildInfo -and $publicChannel) {
    $publicSubscriptions = Get-BackflowSubscriptions -BuildInfo $publicBuildInfo -ChannelName "$publicChannel"
    
    if ($publicSubscriptions.Count -gt 0) {
        Write-ColorOutput "Found $($publicSubscriptions.Count) backflow subscription(s) for public build`n" -ForegroundColor Green
        
        $publicResults = Get-BackflowStatusForBuild -VmrPath $VmrPath -BuildInfo $publicBuildInfo -CurrentCommit $publicBuildInfo.commit -Subscriptions $publicSubscriptions -BuildLabel "Public"
        $allResults += $publicResults
    }
    else {
        Write-ColorOutput "No backflow subscriptions found for public channel: $publicChannel" -ForegroundColor Yellow
    }
}

# Display results
Write-ColorOutput "`n=== Backflow Status Summary ===" -ForegroundColor Green

if ($isInternalBuild) {
    Write-ColorOutput "Internal Build: $BuildId (branch: $branch, channel: $channel)" -ForegroundColor Cyan
    if ($publicBuildInfo) {
        Write-ColorOutput "Public Build: $($publicBuildInfo.id) (branch: $($publicBuildInfo.branch -replace '^refs/heads/', ''), channel: $publicChannel)" -ForegroundColor Cyan
    }
}
else {
    Write-ColorOutput "Build: $BuildId (branch: $branch, channel: $channel)" -ForegroundColor Cyan
}

Write-ColorOutput ""

# Add status symbols to results for table display
$tableResults = $allResults | ForEach-Object {
    [PSCustomObject]@{
        Status = "$(Get-StatusSymbol -Status $_.Status)"
        Build = $_.BuildLabel
        TargetRepo = Get-SimplifiedRepoName -RepoUrl $_.TargetRepo
        TargetBranch = $_.TargetBranch
        Details = $_.Details
    }
}

# Display as table
$tableResults | Format-Table -AutoSize -Wrap

Write-ColorOutput "`nAnalysis complete." -ForegroundColor Green
