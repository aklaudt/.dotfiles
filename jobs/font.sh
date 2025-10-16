#!/usr/bin/env bash
# Install Caskaydia Cove Nerd Font on Linux or WSL.
# - Native Linux: installs to ~/.local/share/fonts (or $XDG_DATA_HOME/fonts) and refreshes font cache.
# - WSL: installs to Linux font dir above AND tries to copy into Windows host fonts at /mnt/c/Windows/Fonts.
# Exits on first error.

set -euo pipefail

URL="${URL:-https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip}"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' is required." >&2; exit 1; }; }
need_cmd unzip
# Prefer curl; fall back to wget
DL_CMD=""
if command -v curl >/dev/null 2>&1; then
  DL_CMD=(curl -fL --retry 3 --connect-timeout 10 -o)
elif command -v wget >/dev/null 2>&1; then
  DL_CMD=(wget -O)
else
  echo "Error: need 'curl' or 'wget'." >&2
  exit 1
fi

is_wsl() {
  [[ -f /proc/sys/kernel/osrelease ]] && grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease
}

# Linux per-user font dir
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  LINUX_FONT_DIR="$XDG_DATA_HOME/fonts"
else
  LINUX_FONT_DIR="$HOME/.local/share/fonts"
fi

# Windows Fonts path when running under WSL
WIN_FONTS_DIR="/mnt/c/Windows/Fonts"

tmpdir="$(mktemp -d)"
zipfile="$tmpdir/CascadiaCode.zip"

echo "Installing Caskaydia Cove Nerd Font"
echo "Source: $URL"

mkdir -p "$LINUX_FONT_DIR"
echo "Downloading..."
"${DL_CMD[@]}" "$zipfile" "$URL"

echo "Unpacking..."
unzip -qq -o "$zipfile" -d "$tmpdir/unzipped"

mapfile -t font_files < <(find "$tmpdir/unzipped" -type f \( -iname '*.ttf' -o -iname '*.otf' \) | sort)
if ((${#font_files[@]} == 0)); then
  echo "Error: no .ttf/.otf files found in ZIP." >&2
  exit 1
fi

echo "Copying to Linux font directory: $LINUX_FONT_DIR"
for f in "${font_files[@]}"; do
  cp -f "$f" "$LINUX_FONT_DIR/"
done

if command -v fc-cache >/dev/null 2>&1; then
  echo "Refreshing font cache..."
  fc-cache -f "$LINUX_FONT_DIR"
else
  echo "Warning: 'fc-cache' not found; fonts will load after next cache refresh/login."
fi

if is_wsl; then
  echo "WSL detected."
  if [[ -d "$WIN_FONTS_DIR" && -w "$WIN_FONTS_DIR" ]]; then
    echo "Copying to Windows host fonts: $WIN_FONTS_DIR"
    for f in "${font_files[@]}"; do
      # Windows ignores exact duplicates; overwrite to be safe.
      cp -f "$f" "$WIN_FONTS_DIR"/
    done
    echo "Fonts available to Windows apps after they refresh their font list."
  else
    echo "Note: Can't write to $WIN_FONTS_DIR (admin required). Skipping Windows host install."
  fi
fi

echo "Installed ${#font_files[@]} font files."
echo "Done."
