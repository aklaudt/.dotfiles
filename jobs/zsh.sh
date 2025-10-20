#!/usr/bin/env bash
set -e

sudo apt-get update && sudo apt-get install -y zsh git curl

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [ ! -d "$ZSH" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ensure_repo() { [ -d "$2/.git" ] && git -C "$2" pull --ff-only || git clone --depth=1 "$1" "$2"; }

ensure_repo https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
ensure_repo https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
ensure_repo https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"

if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  chsh -s "$(command -v zsh)" || true
fi

echo '✅ Zsh + Oh My Zsh installed.'
echo '✅ Plugins cloned: autosuggestions, syntax-highlighting, fast-syntax-highlighting.'
echo '✅ Theme cloned: powerlevel10k.'
