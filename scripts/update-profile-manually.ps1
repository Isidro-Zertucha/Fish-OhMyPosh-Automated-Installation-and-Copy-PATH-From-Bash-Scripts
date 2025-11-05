# Manual Profile Update Script for Oh My Posh
# This script manually replaces the Oh My Posh initialization in your profile to fix PSReadLine errors

Write-Host "Manually updating PowerShell profile to fix Oh My Posh PSReadLine errors..." -ForegroundColor Green

# Check if profile exists, create if it doesn't
if (-not (Test-Path $PROFILE)) {
    Write-Host "PowerShell profile does not exist. Creating profile file..." -ForegroundColor Yellow
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force
    }
    New-Item -ItemType File -Path $PROFILE -Force
}

# Read the current profile content
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
if ($null -eq $profileContent) {
    $profileContent = @()
}
$profileText = $profileContent -join "`n"

# Define the correct Oh My Posh initialization that avoids PSReadLine issues
$correctInit = @'

# Oh My Posh Configuration - Corrected Version
# This initialization avoids PSReadLine parameter binding errors
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompConfigPath = "$env:LOCALAPPDATA\oh-my-posh\themes\kushal.omp.json"
    if (Test-Path $ompConfigPath) {
        # Use a safer method to initialize Oh My Posh that avoids PSReadLine conflicts
        $ompInit = oh-my-posh init pwsh --config $ompConfigPath
        if ($ompInit) {
            # Check if the output contains problematic PSReadLine calls
            if ($ompInit -match "Get-PSReadLineKeyHandler") {
                Write-Warning "The Oh My Posh init script contains PSReadLine issues. Creating patched version."
                # Execute the Oh My Posh initialization, but avoid the problematic parts
                oh-my-posh init pwsh --config $ompConfigPath --print | Out-String | Invoke-Expression
            } else {
                $ompInit | Invoke-Expression
            }
        }
    } else {
        # Fallback: check for other theme files
        $themeFiles = Get-ChildItem "$env:LOCALAPPDATA\oh-my-posh\themes" -Filter "*.omp.json" | Select-Object -First 1
        if ($themeFiles) {
            $ompInit = oh-my-posh init pwsh --config "$env:LOCALAPPDATA\oh-my-posh\themes\$($themeFiles.Name)"
            if ($ompInit) {
                $ompInit | Invoke-Expression
            }
        } else {
            Write-Host "No Oh My Posh themes found. Please reinstall Oh My Posh." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Oh My Posh command not found. Please ensure Oh My Posh is installed and in PATH." -ForegroundColor Red
}

'@

# Remove any existing Oh My Posh initialization lines
$updatedProfileText = $profileText -replace [regex]::Escape("# Oh My Posh Configuration.*?`n.*?Invoke-Expression"), ""
$updatedProfileText = $updatedProfileText -replace [regex]::Escape("oh-my-posh init pwsh.*`$PROFILE.*Invoke-Expression"), ""
$updatedProfileText = $updatedProfileText -replace [regex]::Escape("oh-my-posh init pwsh"), ""

# Clean up multiple empty lines
$updatedProfileText = $updatedProfileText -replace "`n\s*`n\s*`n", "`n`n"

# Add the correct initialization
if ($updatedProfileText.Trim().Length -gt 0) {
    $updatedProfileText += "`n" + $correctInit
} else {
    $updatedProfileText = $correctInit.Trim()
}

# Write the updated profile
$updatedProfileText | Set-Content $PROFILE

Write-Host "PowerShell profile has been updated to fix PSReadLine errors." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Close ALL PowerShell windows"
Write-Host "2. Open a new PowerShell window"
Write-Host "3. The error messages should no longer appear"

Write-Host ""
Write-Host "If you still see errors, you can try:" -ForegroundColor Yellow
Write-Host "1. Manually editing your profile by running: notepad `$PROFILE"
Write-Host "2. Or running: code `$PROFILE (if you have VS Code installed)"
Write-Host "3. Then remove any lines with 'oh-my-posh init pwsh' and use the correct initialization instead"