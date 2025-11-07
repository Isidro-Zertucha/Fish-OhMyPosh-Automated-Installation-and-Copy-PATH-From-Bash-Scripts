#!/usr/bin/env bash
# Sync Bash PATH to Fish PATH (Updated)
# This script synchronizes the PATH environment variable from bash to fish shell
# It now sources bash initialization files to get complete PATH including NVM, SDKMAN, etc.
set -euo pipefail

FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"
[ -f "$FISH_CONFIG" ] || touch "$FISH_CONFIG"

# Backup
cp "$FISH_CONFIG" "${FISH_CONFIG}.bak.$(date +%s)}"

# Read original content
orig=$(cat "$FISH_CONFIG")

marker='# Automatically synced from Bash'

# Temp file
tmp=$(mktemp)

# Write single header
printf '%s\n' "$marker" > "$tmp"

# Function to get PATH after sourcing bash config files to capture NVM, SDKMAN, etc.
get_complete_path() {
    # Create a temporary script containing commands to source necessary files and output PATH
    local temp_script=$(mktemp)
    
    # Create script to source the bashrc (which includes NVM and SDKMAN) and output PATH
    cat > "$temp_script" << 'EOF'
# Source .profile if it exists
if [ -f "$HOME/.profile" ] && [ -r "$HOME/.profile" ]; then
    source "$HOME/.profile" 2>/dev/null
fi

# Source .bash_profile if it exists instead of .bashrc
if [ -f "$HOME/.bash_profile" ] && [ -r "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile" 2>/dev/null
elif [ -f "$HOME/.bash_login" ] && [ -r "$HOME/.bash_login" ]; then
    source "$HOME/.bash_login" 2>/dev/null
elif [ -f "$HOME/.bashrc" ] && [ -r "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null
fi

# Output the resulting PATH
echo "$PATH"
EOF

    # Use bash --rcfile to source our temp script and get the PATH
    local complete_path
    complete_path=$(HOME="$HOME" bash --rcfile "$temp_script" -c 'echo $PATH' 2>/dev/null)
    
    # Fallback: if the above failed, try running the script directly
    if [ -z "$complete_path" ] || [ "$complete_path" = ":" ]; then
        complete_path=$(bash -c "source $temp_script 2>/dev/null || echo \$PATH")
    fi
    
    # Clean up
    rm -f "$temp_script"
    
    # If we still don't have a good PATH, return the original
    if [ -z "$complete_path" ] || [ "$complete_path" = ":" ]; then
        echo "$PATH"
    else
        echo "$complete_path"
    fi
}

# Get the complete PATH after sourcing bash configurations
COMPLETE_PATH=$(get_complete_path)

# Add PATH entries (only existing dirs, no duplicates in output)
IFS=':' read -ra PATH_ARR <<< "$COMPLETE_PATH"
declare -A seen
for dir in "${PATH_ARR[@]}"; do
  dir=$(printf '%s' "$dir" | xargs) || true
  [ -z "$dir" ] && continue
  [ -d "$dir" ] || continue
  if [ -z "${seen[$dir]:-}" ]; then
    printf 'fish_add_path %s\n' "$dir" >> "$tmp"
    seen[$dir]=1
  fi
done

# Append original content with any previous fish_add_path lines and any previous marker removed
# Remove lines that are the marker or start with fish_add_path, and also avoid leaving immediate extra blank line
printf '%s\n' "$orig" | awk -v marker="$marker" '
  BEGIN{first=1}
  $0==marker {next}
  /^fish_add_path[[:space:]]/ {next}
  {
    if (first && $0=="") next
    print
    first=0
  }
' >> "$tmp"

# Ensure no trailing duplicate blank line
awk 'NF{print}' "$tmp" > "${tmp}.clean"
mv "${tmp}.clean" "$tmp"

mv "$tmp" "$FISH_CONFIG"

# Ensure Oh My Posh init line exists
OMP_LINE='oh-my-posh init fish --config $HOME/.poshthemes/kushal.omp.json | source'
if ! grep -Fxq "$OMP_LINE" "$FISH_CONFIG"; then
  printf '%s\n' "$OMP_LINE" >> "$FISH_CONFIG"
fi

# Ensure interactive block exists
if ! grep -Fxq "if status is-interactive" "$FISH_CONFIG"; then
  cat >> "$FISH_CONFIG" <<'FISHBLOCK'

if status is-interactive
    # Commands to run in interactive sessions can go here
end
FISHBLOCK
fi

# Function to detect and add support for bash-based environment managers
{
    # Check for existing bash proxy definitions to avoid duplicates
    if ! grep -q "Generic function for sdk" "$FISH_CONFIG" 2>/dev/null; then
        if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
            cat >> "$FISH_CONFIG" <<'SDKPROXY'

# Generic function for sdk - runs in bash with proper initialization
function sdk
    env HOME="$HOME" bash -c "source $HOME/.sdkman/bin/sdkman-init.sh; sdk $argv"
end
SDKPROXY
        fi
    fi

    if ! grep -q "Generic function for nvm" "$FISH_CONFIG" 2>/dev/null; then
        if [ -f "$HOME/.nvm/nvm.sh" ]; then
            cat >> "$FISH_CONFIG" <<'NVMPROXY'

# Generic function for nvm - runs in bash with proper initialization
function nvm
    env HOME="$HOME" bash -c "source $HOME/.nvm/nvm.sh; nvm $argv"
end

# Generic function for node - runs in bash with proper initialization
function node
    env HOME="$HOME" bash -c "source $HOME/.nvm/nvm.sh; node $argv"
end

# Generic function for npm - runs in bash with proper initialization
function npm
    env HOME="$HOME" bash -c "source $HOME/.nvm/nvm.sh; npm $argv"
end

# Generic function for npx - runs in bash with proper initialization
function npx
    env HOME="$HOME" bash -c "source $HOME/.nvm/nvm.sh; npx $argv"
end
NVMPROXY
        fi
    fi

    # Example for adding other tools in the future
    # if [ -f "$HOME/.rbenv/bin/rbenv" ] && ! grep -q "Generic function for rbenv" "$FISH_CONFIG" 2>/dev/null; then
    #     cat >> "$FISH_CONFIG" <<'RBENVPROXY'
    # # Generic function for rbenv - runs in bash with proper initialization
    # function rbenv
    #     env HOME="$HOME" bash -c "source $HOME/.rbenv/libexec/rbenv; rbenv $argv"
    # end
    # RBENVPROXY
    # fi
    
    # Add more tools as needed...
} 2>/dev/null  # Suppress any errors if directories don't exist

echo "Sync complete. Paths replaced in $FISH_CONFIG."
echo "This version now sources bash initialization files to capture NVM, SDKMAN, and other dynamic PATH additions."
echo "Note: For tools that use shell functions, special functions are created that run commands in a bash subshell."