#!/usr/bin/env bash

set -euo pipefail

PACKAGES=(
  build-essential
  git
  ripgrep
  fzf
  dos2unix
  eza
  cmake
  clang
  clang-tidy
)

echo "Updating package index..."
sudo apt-get update -y

echo "Installing development tools..."
sudo apt-get install -y "${PACKAGES[@]}"

echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean -y

echo "Verifying installs..."
for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo "✔  $pkg installed"
  else
    echo "✖  $pkg failed to install" >&2
    exit 1
  fi
done

echo "All requested packages installed successfully."

