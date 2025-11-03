#!/usr/bin/env bash
# Sync Bash PATH to Fish PATH
# This script synchronizes the PATH environment variable from bash to fish shell
set -euo pipefail

FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"
[ -f "$FISH_CONFIG" ] || touch "$FISH_CONFIG"

# Backup
cp "$FISH_CONFIG" "${FISH_CONFIG}.bak.$(date +%s)"

# Read original content
orig=$(cat "$FISH_CONFIG")

marker='# Automatically synced from Bash'

# Temp file
tmp=$(mktemp)

# Write single header
printf '%s\n' "$marker" > "$tmp"

# Add current PATH entries (only existing dirs, no duplicates in output)
IFS=':' read -ra PATH_ARR <<< "${PATH:-}"
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

echo "Sync complete. Paths replaced in $FISH_CONFIG."

