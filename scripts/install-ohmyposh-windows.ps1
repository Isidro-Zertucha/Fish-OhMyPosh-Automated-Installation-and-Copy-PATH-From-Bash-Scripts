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

# Download FiraCode Nerd Font with verification
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
$fontZipPath = "$env:TEMP\FiraCode.zip"

Write-Host "Downloading Nerd Font..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath -ErrorAction Stop
    
    # Verify the zip file is valid before extracting
    if (Test-Path $fontZipPath) {
        $fileInfo = Get-Item $fontZipPath
        if ($fileInfo.Length -eq 0) {
            throw "Downloaded file is empty"
        }
        
        Write-Host "Verifying downloaded font archive integrity..." -ForegroundColor Cyan
        # Try to test the archive before extracting
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($fontZipPath)
            $archive.Dispose()
            Write-Host "Font archive verified successfully" -ForegroundColor Green
        } catch {
            Write-Host "Font archive verification failed: $($_.Exception.Message)" -ForegroundColor Red
            # Try redownloading if verification fails
            Write-Host "Retrying download..." -ForegroundColor Yellow
            Remove-Item $fontZipPath -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath -ErrorAction Stop
        }
    }
} catch {
    Write-Host "Failed to download font archive: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Skipping font installation. You may install fonts manually later." -ForegroundColor Yellow
    $fontsDownloaded = $false
} 

$fontsDownloaded = $true

if ($fontsDownloaded) {
    # Extract font files with error handling
    $fontExtractPath = "$env:TEMP\FiraCode"
    try {
        # Remove any existing extraction directory
        if (Test-Path $fontExtractPath) {
            Remove-Item $fontExtractPath -Recurse -Force
        }
        
        Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force -ErrorAction Stop
        
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
        
        # Clean up extracted files
        Remove-Item $fontExtractPath -Recurse -Force
    } catch {
        Write-Host "Error extracting font archive: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Font installation may not have completed successfully." -ForegroundColor Yellow
    }
    
    # Clean up zip file
    Remove-Item $fontZipPath -ErrorAction SilentlyContinue
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

# Download themes with verification
$themesUrl = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"
$themesZipPath = "$themesPath\themes.zip"

Write-Host "Downloading Oh My Posh themes..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $themesUrl -OutFile $themesZipPath -ErrorAction Stop
    
    # Verify the zip file is valid before extracting
    if (Test-Path $themesZipPath) {
        $fileInfo = Get-Item $themesZipPath
        if ($fileInfo.Length -eq 0) {
            throw "Downloaded themes file is empty"
        }
        
        Write-Host "Verifying downloaded themes archive integrity..." -ForegroundColor Cyan
        # Try to test the archive before extracting
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [System.IO.Compression.ZipFile]::OpenRead($themesZipPath)
            $archive.Dispose()
            Write-Host "Themes archive verified successfully" -ForegroundColor Green
        } catch {
            Write-Host "Themes archive verification failed: $($_.Exception.Message)" -ForegroundColor Red
            # Try redownloading if verification fails
            Write-Host "Retrying download..." -ForegroundColor Yellow
            Remove-Item $themesZipPath -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Invoke-WebRequest -Uri $themesUrl -OutFile $themesZipPath -ErrorAction Stop
        }
    }
} catch {
    Write-Host "Failed to download themes archive: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Skipping themes installation. You may install themes manually later." -ForegroundColor Yellow
    $themesDownloaded = $false
}

$themesDownloaded = $true

if ($themesDownloaded) {
    try {
        # Extract themes with error handling
        Expand-Archive -Path $themesZipPath -DestinationPath $themesPath -Force -ErrorAction Stop
        
        # Clean up
        Remove-Item $themesZipPath -ErrorAction SilentlyContinue
        Write-Host "Oh My Posh themes installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error extracting themes archive: $($_.Exception.Message)" -ForegroundColor Red
    }
}

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

# Create a more robust Oh My Posh initialization that prevents PSReadLine errors
$robustInitLine = @'

# Oh My Posh Configuration - Robust Version
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

# Add Oh My Posh initialization to PowerShell profile
$profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue

# Check if there's existing Oh My Posh configuration that might cause PSReadLine errors
$existingOhMyPosh = $false
if ($profileContent) {
    foreach ($line in $profileContent) {
        if ($line -match "oh-my-posh init pwsh" -and $line -match "Invoke-Expression") {
            $existingOhMyPosh = $true
            break
        }
    }
}

if ($existingOhMyPosh) {
    Write-Host "Found existing Oh My Posh configuration that may cause PSReadLine errors." -ForegroundColor Yellow
    Write-Host "Replacing with robust initialization..." -ForegroundColor Cyan
    
    # Remove old Oh My Posh initialization
    $updatedProfile = @()
    $skipNextLine = $false
    foreach ($line in $profileContent) {
        if ($skipNextLine) {
            $skipNextLine = $false
            continue
        }
        
        if ($line -match "oh-my-posh init pwsh" -and ($line -match "Invoke-Expression" -or $line -match "# Oh My Posh Configuration")) {
            # Skip this line and potentially the next line if it's a continuation
            $skipNextLine = $true
            continue
        }
        
        # Check if this is the single line containing both commands
        if ($line -match "oh-my-posh init pwsh.*Invoke-Expression") {
            continue
        }
        
        $updatedProfile += $line
    }
    
    # Add the robust initialization
    $updatedProfile += $robustInitLine
    
    # Write the updated profile
    $updatedProfile | Set-Content $PROFILE
    Write-Host "Updated PowerShell profile with robust Oh My Posh initialization" -ForegroundColor Green
} else {
    # Check if the robust initialization is already present
    $profileText = $profileContent -join "`n"
    if ($profileText -notmatch [regex]::Escape($robustInitLine).Replace('\#', '#')) {
        Add-Content -Path $PROFILE -Value $robustInitLine
        Write-Host "Added robust Oh My Posh initialization to PowerShell profile" -ForegroundColor Green
    } else {
        Write-Host "Robust Oh My Posh initialization already present in PowerShell profile" -ForegroundColor Green
    }
}

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart your PowerShell terminal"
Write-Host "2. Set your terminal font to a Nerd Font (e.g., FiraCode NF) in terminal settings"
Write-Host "3. You can customize your prompt by choosing different themes from $themesPath"