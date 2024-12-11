#!/usr/bin/env bash

COMMON_PREFIX="/home/andrewklaudt/../../mnt/c"

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find "$COMMON_PREFIX/personal" "$COMMON_PREFIX/repos" -mindepth 1 -maxdepth 1 -type d | sed "s|^$COMMON_PREFIX/||" | sort | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# Add the common prefix back to the selected path
selected="$COMMON_PREFIX/$selected"
selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Check if tmux is running and create a new session if necessary
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -d -s $selected_name -c "$selected" -n "nvim" "nvim ."
    tmux new-window -t "$selected_name" -n "other"
    tmux switch-client -t "$selected_name"
    exit 0
fi

# Create a new session if it doesn't already exist
if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -d -s "$selected_name" -c "$selected" -n "nvim" "nvim ."
    tmux new-window -t "$selected_name" -n "other"
    tmux switch-client -t "$selected_name"
fi

tmux switch-client -t "$selected_name"
tmux send-keys -t "$selected_name" "cd $selected" C-m
tmux select-window -t "$selected_name:nvim"
