# Fish and Oh My Posh Installation Scripts

This repository contains shell scripts to help you set up Fish shell with Oh My Posh and synchronize your bash PATH to fish PATH.

## Scripts

### 1. Fish and Oh My Posh Installation

The `install-fish-ohmyposh.sh` script automatically:
- Installs Fish shell using your system's package manager (supports apt, dnf, pamac, pacman, zypper)
- Sets Fish as your default shell
- Installs Oh My Posh
- Downloads and installs Nerd Fonts (FiraCode)
- Downloads Oh My Posh themes
- Configures Oh My Posh in your Fish shell with the montys theme

### 2. Bash PATH to Fish PATH Synchronization

The `sync-bash-path-to-fish-path.sh` script:
- Synchronizes your current bash PATH environment variable to your fish configuration
- Preserves existing fish configuration while adding PATH entries
- Creates backups of your existing fish configuration

## Usage

### Option 1: Execute directly from GitHub (Review first!)

**IMPORTANT**: Before running these commands, review the scripts on GitHub to ensure you're comfortable with what they do.

For Fish and Oh My Posh installation:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh.sh | bash
```

For PATH synchronization:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/sync-bash-path-to-fish-path.sh | bash
```

### Option 2: Download, review, then execute

For Fish and Oh My Posh installation:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/install-fish-ohmyposh.sh -o install-fish-ohmyposh.sh
# Review the script contents
cat install-fish-ohmyposh.sh
# Execute if you're satisfied
bash install-fish-ohmyposh.sh
```

For PATH synchronization:
```bash
curl -fsSL https://raw.githubusercontent.com/Isidro-Zertucha/Fish-OhMyPosh-Automated-Installation-and-Copy-PATH-From-Bash-Scripts/main/scripts/sync-bash-path-to-fish-path.sh -o sync-bash-path-to-fish-path.sh
# Review the script contents
cat sync-bash-path-to-fish-path.sh
# Execute if you're satisfied
bash sync-bash-path-to-fish-path.sh
```

## Security Notice

These scripts require `sudo` access to install Fish and Oh My Posh to system directories. Always review scripts before running them directly from the internet, especially ones that require elevated privileges.

## Prerequisites

- `sudo` access
- A Linux system with one of the supported package managers (apt, dnf, pamac, pacman, zypper)
- `curl` or `wget` for downloading dependencies

## License

This project is licensed under the terms in the LICENSE file.