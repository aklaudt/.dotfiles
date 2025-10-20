# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Update path mappings
export PATH="/home/andrewklaudt/.local/bin:$PATH"

# # Map to Docker Daemon running in windows
# export DOCKER_HOST=tcp://localhost:2375

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    copypath
    )

source $ZSH/oh-my-zsh.sh

# User configuration
function tmux_sessionizer() {
  ~/.config/bin/tmux-sessionizer.sh "$@"
}

zle -N tmux_sessionizer

bindkey '^[[Z' autosuggest-execute
bindkey '^P' tmux_sessionizer 

#Aliases
alias ls='exa --icons'
alias cat='batcat'
alias tree="exa --icons --tree"
alias nv="nvim ."
alias lg="lazygit"

typeset -A program_extensions
program_extensions=(
  keil "*.uvproj*"
  utopia "*.iox*"
  excel "*.xlsx"
)

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

open_with() {
  local prog="$1"
  shift

  if [[ -z "$prog" ]]; then
    echo "Usage: open_with <program_name>"
    return 1
  fi

  if [[ -z "${program_extensions[$prog]}" ]]; then
    echo "No mappings found for program '$prog'"
    return 1
  fi

  local find_expr=()
  local first=1
  for pattern in ${program_extensions[$prog]}; do
    if (( first )); then
      find_expr+=(-iname "$pattern")
      first=0
    else
      find_expr+=(-o -iname "$pattern")
    fi
  done

  find . -maxdepth 5 \( "${find_expr[@]}" \) -print | sort -n | fzf --preview 'batcat --style=numbers --color=always {}' --height 70% --tmux 70% | xargs -r cmd.exe /C start
}

ow() {
  open_with "$@"
}

cf() {
  local file
  file=$(find . -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h" \) | fzf)

  if [[ -n "$file" ]]; then
    echo "Formatting $file..."
    clang-format -i "$file"
    echo "Done."
  else
    echo "No file selected."
  fi
}

alias sm="git submodule update --init --recursive"
alias smf="git submodule update --init --recursive --force"

# Alias for initializing SSH Agent
alias ssh-init='eval "$(ssh-agent -s)" && for key in ~/.ssh/*; do [[ -f "$key" && "$(head -c 5 "$key")" == "-----" ]] && ssh-add "$key"; done'
alias copypath="wslpath -w $(pwd) | clip.exe"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Map NVP/node source
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

