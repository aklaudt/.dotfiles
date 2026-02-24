#!/usr/bin/env bash

set -euo pipefail

echo "Installing tmux..."
sudo apt-get update -y
sudo apt-get install -y tmux

if dpkg -s tmux >/dev/null 2>&1; then
  echo "✔  tmux installed"
else
  echo "✖  tmux failed to install" >&2
  exit 1
fi

echo "Installing TPM (Tmux Plugin Manager)..."
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
  echo "TPM already installed, updating..."
  git -C "$TPM_DIR" pull
else
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins"

echo "tmux setup complete."
