# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;44:cd=33;44:su=31;41:sg=30;43:tw=30;42:ow=37;41'
source $ZSH/oh-my-zsh.sh

# User configuration


# starting dir
cd ~/../../mnt/c/repos


SPACESHIP_PROMPT_ADD_NEWLINE="true"
SPACESHIP_CHAR_SYMBOL="⚡"

# Turn off power status when using spaceship prompt
export SPACESHIP_BATTERY_SHOW=false
