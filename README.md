# Fish and Oh My Posh Installation Scripts

This repository contains scripts to help you set up Fish shell with Oh My Posh and synchronize your bash PATH to fish PATH on Linux, as well as Oh My Posh for PowerShell on Windows.

## Scripts

### Linux Scripts

#### 1. Fish and Oh My Posh Installation for Linux

The `install-fish-ohmyposh-linux.sh` script automatically:
- Installs Fish shell using your system's package manager (supports apt, dnf, pamac, pacman, zypper)
- Sets Fish as your default shell
- Installs Oh My Posh
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your Fish shell with the kushal theme

#### 2. Bash PATH to Fish PATH Synchronization

The `sync-bash-path-to-fish-path.sh` script (Linux only):
- Synchronizes your current bash PATH environment variable to your fish configuration
- Preserves existing fish configuration while adding PATH entries
- Creates backups of your existing fish configuration

### macOS Script

#### 3. Fish and Oh My Posh Installation for macOS

The `install-fish-ohmyposh-macos.sh` script automatically:
- Checks for and installs Homebrew if not present
- Installs Fish shell using Homebrew
- Sets Fish as your default shell
- Installs Oh My Posh
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your Fish shell with the kushal theme

### Windows Script

#### 4. Oh My Posh Installation for Windows (PowerShell)

The `install-ohmyposh-windows.ps1` PowerShell script:
- Installs Oh My Posh using Chocolatey or Winget (with fallback to manual installation)
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your PowerShell profile with the kushal theme

## Usage

### Linux Usage

#### Option 1: Execute directly from GitHub (Review first!)

**IMPORTANT**: Before running these commands, review the scripts on GitHub to ensure you're comfortable with what they do.

For Fish and Oh My Posh installation on Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh-linux.sh | bash
```

For PATH synchronization on Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/sync-bash-path-to-fish-path.sh | bash
```

#### Option 2: Download, review, then execute

For Fish and Oh My Posh installation on Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh-linux.sh -o install-fish-ohmyposh-linux.sh
# Review the script contents
cat install-fish-ohmyposh-linux.sh
# Execute if you're satisfied
bash install-fish-ohmyposh-linux.sh
```

For PATH synchronization on Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/sync-bash-path-to-fish-path.sh -o sync-bash-path-to-fish-path.sh
# Review the script contents
cat sync-bash-path-to-fish-path.sh
# Execute if you're satisfied
bash sync-bash-path-to-fish-path.sh
```

### macOS Usage

For Fish and Oh My Posh installation on macOS:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh-macos.sh | bash
```

Or download and review first:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh-macos.sh -o install-fish-ohmyposh-macos.sh
# Review the script contents
cat install-fish-ohmyposh-macos.sh
# Execute if you're satisfied
bash install-fish-ohmyposh-macos.sh
```

### Windows Usage

For Oh My Posh installation on Windows (PowerShell), download the script and run it in PowerShell:

```powershell
# Download the script
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-ohmyposh-windows.ps1 -o install-ohmyposh-windows.ps1

# Review the script contents
Get-Content install-ohmyposh-windows.ps1

# Execute if you're satisfied (run in PowerShell as Administrator for best results)
./install-ohmyposh-windows.ps1
```

Note: The Windows script requires PowerShell and works best when run with Administrator privileges.

## Security Notice

The Linux and macOS scripts require `sudo` access to install Fish and Oh My Posh to system directories. The Windows PowerShell script may require Administrator privileges for optimal installation. Always review scripts before running them directly from the internet, especially ones that require elevated privileges.

## Prerequisites

### Linux:
- `sudo` access
- A Linux system with one of the supported package managers (apt, dnf, pamac, pacman, zypper)
- `curl` or `wget` for downloading dependencies

### macOS:
- `sudo` access
- macOS 10.12 or later
- Homebrew (will be installed automatically if not present)
- `curl` or `wget` for downloading dependencies

### Windows:
- Windows 10 or 11
- PowerShell 5.1 or later
- Internet connection for downloading dependencies
- Administrator privileges recommended for optimal installation

## License

This project is licensed under the terms in the LICENSE file.