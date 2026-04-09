#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/.nvim-version"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: $VERSION_FILE not found. Create it with the desired version tag (e.g., release-0.11)"
  exit 1
fi

VERSION=$(cat "$VERSION_FILE")
NVIM_DIR="$HOME/personal/neovim"

# Remove existing neovim directory if it exists to ensure clean build
if [[ -d "$NVIM_DIR" ]]; then
  echo "Removing existing neovim directory..."
  rm -rf "$NVIM_DIR"
fi

git clone -b "$VERSION" https://github.com/neovim/neovim.git "$NVIM_DIR"
sudo apt install cmake gettext lua5.1 liblua5.1-0-dev

cd "$NVIM_DIR"
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

echo "✓ Neovim $VERSION installed successfully"
