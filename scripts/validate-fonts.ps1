# Font Validation Script for Oh My Posh
# This script checks if Nerd Fonts are properly installed and available to terminals

Write-Host "Checking for installed Nerd Fonts..." -ForegroundColor Green

# Function to check if a specific font is installed
function Test-FontInstalled {
    param([string]$FontName)
    
    # Check both system and user fonts directories
    $systemFonts = Get-ChildItem "$env:windir\Fonts" -Name -ErrorAction SilentlyContinue
    $userFonts = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -Name -ErrorAction SilentlyContinue
    
    # Combine both lists
    $allFonts = $systemFonts + $userFonts
    
    # Check if the font exists (case-insensitive partial match)
    foreach ($font in $allFonts) {
        if ($font -like "*$FontName*") {
            return $true
        }
    }
    return $false
}

# Function to get all installed fonts containing a pattern
function Get-InstalledFontsLike {
    param([string]$Pattern)
    
    $systemFonts = Get-ChildItem "$env:windir\Fonts" -Name -ErrorAction SilentlyContinue
    $userFonts = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -Name -ErrorAction SilentlyContinue
    
    # Combine both lists
    $allFonts = $systemFonts + $userFonts
    
    $matchingFonts = @()
    foreach ($font in $allFonts) {
        if ($font -like "*$Pattern*") {
            $matchingFonts += $font
        }
    }
    return $matchingFonts
}

# Check for FiraCode Nerd Font specifically
Write-Host "`nChecking for FiraCode Nerd Font..." -ForegroundColor Yellow
$firaCodeFound = Test-FontInstalled -FontName "FiraCode"

if ($firaCodeFound) {
    Write-Host "✓ FiraCode Nerd Font is installed" -ForegroundColor Green
    
    # Get all matching fonts
    $firaFonts = Get-InstalledFontsLike -Pattern "FiraCode"
    Write-Host "Found the following FiraCode fonts:" -ForegroundColor Cyan
    foreach ($font in $firaFonts) {
        Write-Host "  - $font" -ForegroundColor White
    }
} else {
    Write-Host "✗ FiraCode Nerd Font is NOT installed" -ForegroundColor Red
}

# Check for other common Nerd Fonts
Write-Host "`nChecking for other common Nerd Fonts..." -ForegroundColor Yellow
$otherNerdFonts = @("Hack", "Cascadia", "DejaVu Sans", "Source Code")

foreach ($font in $otherNerdFonts) {
    $found = Test-FontInstalled -FontName $font
    if ($found) {
        Write-Host "✓ $font Nerd Font is installed" -ForegroundColor Green
    } else {
        Write-Host "- $font Nerd Font not found" -ForegroundColor Gray
    }
}

# Display instructions for setting the font in common terminals
Write-Host "`nTo use the font in your terminal:" -ForegroundColor Yellow

Write-Host "`nFor Windows Terminal:" -ForegroundColor Cyan
Write-Host "1. Open Windows Terminal Settings (Ctrl + ,)"
Write-Host "2. Go to 'Profiles' section, then your profile (PowerShell)"
Write-Host "3. Under 'Appearance', set 'Font face' to 'FiraCode NF' or similar"

Write-Host "`nFor PowerShell ISE:" -ForegroundColor Cyan
Write-Host "1. Go to 'Tools' > 'Options' > 'Fonts And Colors'"
Write-Host "2. Change 'Font' to 'FiraCode NF' or similar"

Write-Host "`nFor Visual Studio Code:" -ForegroundColor Cyan
Write-Host "1. Open Settings (Ctrl + ,)"
Write-Host "2. Search for 'terminal.integrated.fontFamily'"
Write-Host "3. Set to 'FiraCode NF' or similar"

Write-Host "`nNote: If fonts don't appear immediately, you may need to:" -ForegroundColor Yellow
Write-Host "- Restart your terminal application" 
Write-Host "- Restart Windows Explorer (taskbar) or restart your computer"
Write-Host "- Run as Administrator for full system font installation"