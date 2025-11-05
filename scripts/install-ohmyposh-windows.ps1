# Oh My Posh for Windows (PowerShell) Installation Script
# This script installs Oh My Posh, Nerd Fonts, and configures PowerShell

Write-Host "Starting Oh My Posh Windows installation..." -ForegroundColor Green

# Check if running as administrator for some operations
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "Detecting package manager..." -ForegroundColor Yellow

# Try to install via package managers first
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey detected, using it to install Oh My Posh" -ForegroundColor Cyan
    choco install oh-my-posh -y
} elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Winget detected, using it to install Oh My Posh" -ForegroundColor Cyan
    winget install JanDeDobbeleer.OhMyPosh
} else {
    # Fallback to manual installation
    Write-Host "Package managers not found, installing Oh My Posh manually..." -ForegroundColor Yellow
    $installPath = "$env:LOCALAPPDATA\oh-my-posh"
    if (!(Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force
    }
    
    # Download oh-my-posh binary
    $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
    $url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-$arch.exe"
    $binaryPath = "$installPath\oh-my-posh.exe"
    
    Write-Host "Downloading Oh My Posh to $binaryPath" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $binaryPath
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$installPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installPath", "User")
        Write-Host "Added Oh My Posh to PATH. You may need to restart your terminal." -ForegroundColor Green
    }
}

Write-Host "Installing Nerd Fonts..." -ForegroundColor Yellow

# Create fonts directory if it doesn't exist
$fontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (!(Test-Path $fontsPath)) {
    New-Item -ItemType Directory -Path $fontsPath -Force
}

# Download FiraCode Nerd Font
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
$fontZipPath = "$env:TEMP\FiraCode.zip"

Write-Host "Downloading Nerd Font..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath

# Extract font files
$fontExtractPath = "$env:TEMP\FiraCode"
Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force

# Copy FiraCode font files to the Windows Fonts directory with proper registry entries
Get-ChildItem -Path $fontExtractPath -Filter "*FiraCode*" | ForEach-Object {
    $fontSource = $_.FullName
    $fontName = $_.Name

    # Copy to user fonts directory
    $fontDestination = Join-Path $fontsPath $fontName
    Copy-Item $fontSource -Destination $fontDestination -Force

    # For admin users, also copy to system fonts and register in registry
    if ($isAdmin) {
        $systemFontPath = "$env:windir\Fonts\$fontName"
        Copy-Item $fontSource -Destination $systemFontPath -Force

        # Add registry entry for the font (making it system-wide)
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontRegistryName = $fontName -replace '\.ttf|\.otf|\.ttc|\.otc$', ''
        $fontRegistryName += " (TrueType)"
        Set-ItemProperty -Path $registryPath -Name $fontRegistryName -Value $fontName -Force
    } else {
        # For non-admin users, just copy to user fonts directory
        Write-Host "Note: Running as non-administrator. Font installed to user directory only." -ForegroundColor Yellow
    }
}

# Refresh the font cache
Write-Host "Refreshing font cache..." -ForegroundColor Cyan
try {
    # This will try to refresh the font cache by restarting the Windows Font Cache service
    if ($isAdmin) {
        Restart-Service FontCache -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "Could not restart font cache service. Font may require system restart to appear in applications." -ForegroundColor Yellow
}

Write-Host "Installing Oh My Posh themes..." -ForegroundColor Yellow

# Create themes directory
$themesPath = "$env:LOCALAPPDATA\oh-my-posh\themes"
if (!(Test-Path $themesPath)) {
    New-Item -ItemType Directory -Path $themesPath -Force
}

# Download themes
$themesUrl = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"
$themesZipPath = "$themesPath\themes.zip"

Write-Host "Downloading Oh My Posh themes..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $themesUrl -OutFile $themesZipPath

# Extract themes
Expand-Archive -Path $themesZipPath -DestinationPath $themesPath -Force

# Clean up
Remove-Item $themesZipPath -Force

Write-Host "Configuring PowerShell profile..." -ForegroundColor Yellow

# Create PowerShell profile directory if it doesn't exist
$profileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

Write-Host "Looking for kushal theme or configuring Oh My Posh..." -ForegroundColor Yellow

# Look specifically for kushal theme in the themes directory
$kushalThemePath = Get-ChildItem "$env:LOCALAPPDATA\oh-my-posh\themes" -Filter "*kushal*.omp.json" -Recurse | Select-Object -First 1

if ($kushalThemePath) {
    # If kushal theme is found, use it
    $themeName = $kushalThemePath.Name
    $initLine = "oh-my-posh init pwsh --config `"$env:LOCALAPPDATA\oh-my-posh\themes\$themeName`" | Invoke-Expression"
    Write-Host "Found and using kushal theme: $themeName" -ForegroundColor Green
} else {
    # If kushal isn't found, find any available theme as fallback
    $themeFiles = Get-ChildItem "$env:LOCALAPPDATA\oh-my-posh\themes" -Filter "*.omp.json" | Select-Object -First 1
    if ($themeFiles) {
        $themeName = $themeFiles.Name
        Write-Host "kushal theme not found, using $themeName as fallback" -ForegroundColor Yellow
        $initLine = "oh-my-posh init pwsh --config `"$env:LOCALAPPDATA\oh-my-posh\themes\$themeName`" | Invoke-Expression"
    } else {
        Write-Host "No themes found, using default agnoster theme" -ForegroundColor Yellow
        $initLine = 'oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/agnoster.omp.json" | Invoke-Expression'
    }
}

# Check if PSReadLine module is available to avoid issues during initialization
$psreadlineAvailable = Get-Module -ListAvailable -Name "PSReadLine"

if ($psreadlineAvailable) {
    Write-Host "PSReadLine is available" -ForegroundColor Green
} else {
    Write-Host "PSReadLine not available, the script will attempt to install it" -ForegroundColor Yellow
    # Attempt to install PSReadLine if it's not available
    try {
        Install-Module -Name PSReadLine -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
        Write-Host "PSReadLine module installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install PSReadLine module: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "This may cause issues with Oh My Posh functionality." -ForegroundColor Yellow
    }
}

# Add Oh My Posh initialization to PowerShell profile
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue

if ($profileContent -notcontains $initLine) {
    Add-Content -Path $PROFILE -Value "`n# Oh My Posh Configuration"
    Add-Content -Path $PROFILE -Value $initLine
    Write-Host "Added Oh My Posh initialization to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "Oh My Posh initialization already present in PowerShell profile" -ForegroundColor Green
}

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your PowerShell terminal"
Write-Host "2. Set your terminal font to a Nerd Font (e.g., FiraCode NF) in terminal settings"
Write-Host "3. You can customize your prompt by choosing different themes from $themesPath"