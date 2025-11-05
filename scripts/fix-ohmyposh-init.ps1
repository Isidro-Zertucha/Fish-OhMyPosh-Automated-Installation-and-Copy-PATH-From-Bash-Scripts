# Fix Oh My Posh Initialization Script
# This script addresses the Get-PSReadLineKeyHandler parameter error

Write-Host "Fixing Oh My Posh initialization to resolve Get-PSReadLineKeyHandler errors..." -ForegroundColor Green

# Check PSReadLine version to determine if we need the fix
$psreadlineModule = Get-Module -Name PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if ($null -eq $psreadlineModule) {
    Write-Host "PSReadLine module not found. Attempting to install..." -ForegroundColor Yellow
    try {
        Install-Module -Name PSReadLine -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
        $psreadlineModule = Get-Module -Name PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        Write-Host "PSReadLine module installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install PSReadLine module: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "This may cause issues with Oh My Posh functionality." -ForegroundColor Yellow
    }
}

if ($null -ne $psreadlineModule) {
    Write-Host "PSReadLine version: $($psreadlineModule.Version)" -ForegroundColor Cyan
    if ($psreadlineModule.Version -lt [version]"2.0.0") {
        Write-Host "PSReadLine version is older, which may cause issues with Oh My Posh." -ForegroundColor Yellow
        Write-Host "Attempting to update PSReadLine to latest version..." -ForegroundColor Cyan
        try {
            Update-Module -Name PSReadLine -Force -ErrorAction SilentlyContinue
            Write-Host "PSReadLine updated successfully" -ForegroundColor Green
        } catch {
            Write-Host "Could not update PSReadLine: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# Check if profile file exists
if (-not (Test-Path $PROFILE)) {
    Write-Host "PowerShell profile does not exist. Creating profile file..." -ForegroundColor Yellow
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force
    }
    New-Item -ItemType File -Path $PROFILE -Force
}

# Read current profile content
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
if ($null -eq $profileContent) {
    $profileContent = @()
}

# Look for Oh My Posh initialization and remove problematic lines
$updatedProfileContent = @()
$foundOhMyPoshInit = $false

for ($i = 0; $i -lt $profileContent.Length; $i++) {
    $line = $profileContent[$i]
    
    # Skip the problematic Oh My Posh initialization
    if ($line -match "oh-my-posh init pwsh" -and $line -match "Invoke-Expression") {
        $foundOhMyPoshInit = $true
        Write-Host "Found problematic Oh My Posh initialization line, will replace with fixed version" -ForegroundColor Yellow
        continue
    }
    
    # Add all other lines
    $updatedProfileContent += $line
}

# Add a more robust Oh My Posh initialization that handles PSReadLine compatibility
$fixedInitLine = @'
# Oh My Posh Configuration - Fixed Version
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompConfigPath = "$env:LOCALAPPDATA\oh-my-posh\themes\kushal.omp.json"
    if (Test-Path $ompConfigPath) {
        oh-my-posh init pwsh --config $ompConfigPath | Invoke-Expression
    } else {
        # Fallback: use any available theme
        $themeFiles = Get-ChildItem "$env:LOCALAPPDATA\oh-my-posh\themes" -Filter "*.omp.json" | Select-Object -First 1
        if ($themeFiles) {
            oh-my-posh init pwsh --config "$env:LOCALAPPDATA\oh-my-posh\themes\$($themeFiles.Name)" | Invoke-Expression
        } else {
            Write-Host "No Oh My Posh themes found. Please reinstall Oh My Posh." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Oh My Posh command not found. Please ensure Oh My Posh is installed and in PATH." -ForegroundColor Red
}
'@

# Add the fixed initialization if not already present
if ($foundOhMyPoshInit) {
    Write-Host "Adding fixed Oh My Posh initialization to profile..." -ForegroundColor Green
    $updatedProfileContent += ""
    $updatedProfileContent += $fixedInitLine
}

# Write the updated profile content
$updatedProfileContent | Set-Content $PROFILE

Write-Host "Profile has been updated to fix the initialization error." -ForegroundColor Green
Write-Host ""
Write-Host "To apply these changes:" -ForegroundColor Yellow
Write-Host "1. Close and restart your PowerShell terminal completely"
Write-Host "2. The error should no longer appear on startup"
Write-Host ""
Write-Host "If you still have issues, you may need to:" -ForegroundColor Yellow
Write-Host "- Run: Get-Module PSReadLine -ListAvailable to check PSReadLine versions"
Write-Host "- Run: Import-Module PSReadLine to reload the module"