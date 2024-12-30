#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/../../mnt/c/repos/ ~/../../mnt/c/personal/ -mindepth 1 -maxdepth 1 -type d | sed -e 's/\/home\/andrewklaudt\/..\/..\/mnt\/c\///' | fzf --height 70% --tmux 70%)
fi

if [[ -z $selected ]]; then
    echo "No selection made. Exiting."
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Start a new tmux session if tmux is not running
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected" -d
    tmux send-keys -t "$selected_name" "nvim" C-m
    tmux split-window -t "$selected_name" -c "$selected"
    tmux attach-session -t "$selected_name"
    exit 0
fi

# Create a new tmux session if it doesn't exist
if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -s "$selected_name" -c "$selected" -d
    tmux send-keys -t "$selected_name" "nvim" C-m
    tmux split-window -t "$selected_name" -c "$selected"
fi

# Switch to the tmux session
if [[ -n $TMUX ]]; then
    tmux switch-client -t "$selected_name"
else
    tmux attach-session -t "$selected_name"
fi
