# Fish and Oh My Posh Installation Scripts

This repository contains scripts to help you set up Fish shell with Oh My Posh and synchronize your bash PATH to fish PATH on Linux and macOS, as well as Oh My Posh for PowerShell on Windows.

## Scripts

### Linux and macOS Scripts

#### 1. Fish and Oh My Posh Installation (Linux/macOS)

The `install-fish-ohmyposh.sh` script automatically:
- Detects your platform (Linux/macOS) and adjusts behavior accordingly
- For Linux: Installs Fish shell using your system's package manager (supports apt, dnf, pamac, pacman, zypper)
- For macOS: Checks for and installs Homebrew if not present, then installs Fish shell using Homebrew
- Sets Fish as your default shell
- Installs Oh My Posh
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your Fish shell with the kushal theme

#### 2. Bash PATH to Fish PATH Synchronization (Linux and macOS)

The `sync-bash-path-to-fish-path.sh` script:
- Synchronizes your current bash PATH environment variable to your fish configuration
- Preserves existing fish configuration while adding PATH entries
- Creates backups of your existing fish configuration

### Windows Script

#### 3. Oh My Posh Installation for Windows (PowerShell)

The `install-ohmyposh-windows.ps1` PowerShell script:
- Installs Oh My Posh using Chocolatey or Winget (with fallback to manual installation)
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your PowerShell profile with the kushal theme

## Available Themes

The scripts install the kushal theme by default, but Oh My Posh offers many other themes. You can browse all available themes at [Oh My Posh Themes](https://ohmypo.sh/docs/themes#kushal). After installation, you can change to a different theme by modifying your shell configuration file with your preferred theme from the gallery.

## Usage

### Linux/macOS

To install Fish shell with Oh My Posh on Linux/macOS, run this command directly in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh.sh | bash
```

To synchronize your bash PATH to fish PATH on Linux/macOS, run this command in your terminal after installing Fish and Oh My Posh (note: this is automatically done at the end of the installation script if you respond "y"):

```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/sync-bash-path-to-fish-path.sh | bash
```

### Windows

To install Oh My Posh on Windows with PowerShell, run this command directly in an Administrator PowerShell terminal (for best results run as Administrator):

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression "& {$(Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-ohmyposh-windows.ps1')}"
```

## Security Notice

The Linux/macOS script requires `sudo` access to install Fish and Oh My Posh to system directories. The Windows PowerShell script may require Administrator privileges for optimal installation. Always review scripts before running them directly from the internet, especially ones that require elevated privileges.

## Prerequisites

### Linux/macOS:
- `sudo` access
- Linux system with one of the supported package managers (apt, dnf, pamac, pacman, zypper), or macOS 10.12+ with Homebrew (will be installed automatically if not present)
- `curl` or `wget` for downloading dependencies

### Windows:
- Windows 10 or 11
- PowerShell 5.1 or later
- Internet connection for downloading dependencies
- Administrator privileges recommended for optimal installation

## License

This project is licensed under the terms in the LICENSE file.