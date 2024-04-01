#!/usr/bin/env bash
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/../../mnt/c/personal/ ~/../../mnt/c/repos/ -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    # Create a new tmux session with two windows
    tmux new-session -d -s $selected_name -c $selected -n "nvim" "nvim ."
    tmux new-window -t $selected_name -n "other"
    tmux switch-client -t $selected_name
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    # Create a new tmux session with two windows
    tmux new-session -d -s $selected_name -c $selected -n "nvim" "nvim ."
    tmux new-window -t $selected_name -n "other"
    tmux switch-client -t $selected_name
fi

tmux switch-client -t $selected_name
tmux send-keys -t $selected_name "cd $selected" C-m
tmux select-window -t $selected_name:nvim
