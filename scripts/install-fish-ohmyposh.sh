#!/usr/bin/env bash
# Fish and Oh My Posh Automated Installation Script
# This script installs Fish shell, Oh My Posh, Nerd Fonts, and configures them
set -euo pipefail

# --- Configuration ---
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
OMP_BINARY_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64"
OMP_THEMES_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"

OMP_BIN="/usr/local/bin/oh-my-posh"
POSHTHEMES_DIR="$HOME/.poshthemes"
FONTS_DIR="$HOME/.local/share/fonts"
FIRACODE_ZIP="$HOME/Downloads/firacode.zip"
THEMES_ZIP="$POSHTHEMES_DIR/themes.zip"
FISH_CONFIG_DIR="$HOME/.config/fish"
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
OMP_INIT_LINE='oh-my-posh init fish --config $HOME/.poshthemes/kushal.omp.json | source'

# --- Helpers ---
info() { printf '\e[1;34m• %s\e[0m\n' "$1"; }
success() { printf '\e[1;32m✓ %s\e[0m\n' "$1"; }
warn() { printf '\e[1;33m! %s\e[0m\n' "$1"; }
err() { printf '\e[1;31m✗ %s\e[0m\n' "$1" >&2; }

if ! command -v sudo >/dev/null 2>&1; then
  err "sudo required but not found. Install sudo or run as root."
  exit 1
fi

# --- Install fish ---
install_fish() {
  info "Detecting package manager..."
  if command -v apt-get >/dev/null 2>&1; then
    info "Using apt to install fish"
    sudo apt-get update
    sudo apt-get install -y fish
  elif command -v dnf >/dev/null 2>&1; then
    info "Using dnf to install fish"
    sudo dnf install -y fish
  elif command -v pamac >/dev/null 2>&1; then
    info "Using pamac to install fish"
    sudo pamac -S --noconfirm fish
  elif command -v pacman >/dev/null 2>&1; then
    info "Using pacman to install fish"
    sudo pacman -Syu --noconfirm fish
  elif command -v zypper >/dev/null 2>&1; then
    info "Using zypper to install fish"
    sudo zypper install -y fish
  else
    warn "No supported package manager detected. You may need to install fish manually."
    return
  fi
  success "fish install step completed."
}

# --- Change default shell to fish ---
set_default_fish() {
  FISH_PATH="$(command -v fish || true)"
  if [ -z "$FISH_PATH" ]; then
    warn "fish not found in PATH; skipping chsh."
    return
  fi
  CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
    success "fish is already the default shell."
    return
  fi
  if ! grep -qFx "$FISH_PATH" /etc/shells 2>/dev/null; then
    info "Adding $FISH_PATH to /etc/shells"
    echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  info "Changing default shell to fish for user $USER"
  if chsh -s "$FISH_PATH" "$USER"; then
    success "Default shell changed to fish. Log out and back in for it to take effect."
  else
    warn "chsh failed. You may need to run: chsh -s $FISH_PATH"
  fi
}

# --- Install Oh My Posh binary ---
install_omp() {
  info "Downloading Oh My Posh binary to $OMP_BIN"
  if command -v wget >/dev/null 2>&1; then
    sudo wget -q "$OMP_BINARY_URL" -O "$OMP_BIN"
  elif command -v curl >/dev/null 2>&1; then
    sudo curl -sL "$OMP_BINARY_URL" -o "$OMP_BIN"
  else
    err "Neither wget nor curl available to download Oh My Posh."
    return
  fi
  sudo chmod +x "$OMP_BIN"
  success "Oh My Posh installed to $OMP_BIN"
}

# --- Install fonts (and cleanup) ---
install_fonts() {
  info "Creating fonts dir: $FONTS_DIR"
  mkdir -p "$FONTS_DIR"
  info "Downloading Nerd Font (FiraCode) to $FIRACODE_ZIP"
  if command -v wget >/dev/null 2>&1; then
    wget -q "$NERD_FONT_URL" -O "$FIRACODE_ZIP"
  elif command -v curl >/dev/null 2>&1; then
    curl -sL "$NERD_FONT_URL" -o "$FIRACODE_ZIP"
  else
    warn "wget/curl not found; cannot download fonts automatically."
    return
  fi
  info "Unzipping fonts to $FONTS_DIR"
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$FIRACODE_ZIP" -d "$FONTS_DIR"
  elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$FIRACODE_ZIP" -C "$FONTS_DIR"
  else
    warn "No unzip/bsdtar; fonts zip left at $FIRACODE_ZIP"
    return
  fi
  info "Refreshing font cache"
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f -v >/dev/null 2>&1 || true
    success "Fonts installed and cache updated."
  else
    warn "fc-cache not found; fonts may not be recognized until you install fontconfig."
  fi
  if [ -f "$FIRACODE_ZIP" ]; then
    rm -f "$FIRACODE_ZIP" && info "Removed $FIRACODE_ZIP"
  fi
}

# --- Install themes (and cleanup) ---
install_themes() {
  info "Creating themes dir: $POSHTHEMES_DIR"
  mkdir -p "$POSHTHEMES_DIR"
  info "Downloading Oh My Posh themes zip to $THEMES_ZIP"
  if command -v wget >/dev/null 2>&1; then
    wget -q "$OMP_THEMES_URL" -O "$THEMES_ZIP"
  elif command -v curl >/dev/null 2>&1; then
    curl -sL "$OMP_THEMES_URL" -o "$THEMES_ZIP"
  else
    warn "wget/curl not found; cannot download themes automatically."
    return
  fi
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$THEMES_ZIP" -d "$POSHTHEMES_DIR"
  elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$THEMES_ZIP" -C "$POSHTHEMES_DIR"
  else
    warn "unzip/bsdtar not available; themes zip left at $THEMES_ZIP"
    return
  fi
  chmod u+rw "$POSHTHEMES_DIR"/*.json 2>/dev/null || true
  rm -f "$THEMES_ZIP" && success "Removed $THEMES_ZIP"
  success "Oh My Posh themes installed to $POSHTHEMES_DIR"
}

# --- Ensure fish config contains OMP init line ---
ensure_fish_config() {
  mkdir -p "$FISH_CONFIG_DIR"
  touch "$FISH_CONFIG_FILE"
  # Append init line if missing
  if ! grep -Fqx "$OMP_INIT_LINE" "$FISH_CONFIG_FILE"; then
    printf '\n# Initialize Oh My Posh\n%s\n' "$OMP_INIT_LINE" >> "$FISH_CONFIG_FILE"
    success "Added Oh My Posh init to $FISH_CONFIG_FILE"
  else
    success "Oh My Posh init already present in $FISH_CONFIG_FILE"
  fi
}

# --- Run steps ---
main() {
  install_fish
  set_default_fish
  install_omp
  install_fonts
  install_themes
  ensure_fish_config

  echo
  success "Installation complete."

  cat <<EOF

Next steps:
- Log out and back in (or restart the shell) for fish to become your login shell.
- To preview themes: oh-my-posh print [theme] or inspect $POSHTHEMES_DIR and change the config path if you prefer a different theme.
- Set your terminal font to the installed Nerd Font (e.g., FiraCode Nerd Font) if prompt looks wrong.

EOF
}

main

