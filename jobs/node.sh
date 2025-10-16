#!/usr/bin/env bash
# Install the latest LTS version of Node.js using the official NodeSource setup.
# Works on Ubuntu/Debian/WSL. Exits immediately on any failure.

set -euo pipefail

echo "Installing Node.js (LTS) ..."

if ! command -v curl >/dev/null 2>&1; then
    echo "Installing curl (required for setup)..."
    sudo apt-get update -y
    sudo apt-get install -y curl
fi

# Import NodeSource setup for LTS (currently Node 20)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install node + npm
sudo apt-get install -y nodejs

# Verify install
echo "Node version: $(node -v)"
echo "NPM version:  $(npm -v)"
echo "Node.js installation complete."

