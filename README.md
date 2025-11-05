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

#### 4. Font Validation Script (Windows)

The `validate-fonts.ps1` PowerShell script:
- Checks if Nerd Fonts are properly installed and available to terminals
- Helps troubleshoot font availability issues
- Provides instructions for setting up fonts in different terminals

#### 5. Oh My Posh Initialization Fix (Windows)

The `fix-ohmyposh-init.ps1` PowerShell script:
- Fixes the Get-PSReadLineKeyHandler error that appears on PowerShell startup
- Updates the PowerShell profile with a more compatible initialization
- Ensures Oh My Posh works properly with different PSReadLine versions

#### 6. Manual Profile Update Script (Windows)

The `update-profile-manually.ps1` PowerShell script:
- Provides an alternative way to manually update your PowerShell profile
- Fixes PSReadLine errors by replacing problematic initialization code
- Offers more control over the Oh My Posh initialization process

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

## Troubleshooting

### Windows Font Issues

If you've installed the fonts but they're not showing up in your terminal:

1. **Run as Administrator**: Make sure you ran the installation script as an Administrator for full font system integration.
2. **Validate Font Installation**: Run the validation script to check if fonts are properly installed:
   ```powershell
   # Navigate to the scripts directory and run the validation script
   .\validate-fonts.ps1
   ```
3. **Restart Your Terminal**: Close and reopen your terminal application completely.
4. **Check Terminal Settings**: Make sure your terminal is configured to use a Nerd Font (e.g., "FiraCode NF").
5. **System Restart**: If fonts still don't appear, restart your computer to ensure Windows properly registers the fonts.

### Common Issues

- **Font not appearing in terminal**: This is usually because the font wasn't properly registered in the system or the terminal isn't configured to use it.
- **Prompt symbols not showing correctly**: This typically means your terminal is not using a Nerd Font that supports the symbols needed by Oh My Posh.
- **Oh My Posh not initializing**: Check your PowerShell profile (`$PROFILE`) to verify the initialization line was added correctly.
- **Get-PSReadLineKeyHandler errors on startup**: If you see red error messages about positional parameters with Spacebar, Enter, or Ctrl+c, run either the `fix-ohmyposh-init.ps1` or `update-profile-manually.ps1` script to update the initialization with a PSReadLine-compatible version.
- **Zip archive extraction errors**: If you see "End of Central Directory record could not be found" errors, this is typically due to incomplete downloads. The updated script now includes verification and retry logic to handle this. If problems persist, you may need to download the zip files manually.

## License

This project is licensed under the terms in the LICENSE file.