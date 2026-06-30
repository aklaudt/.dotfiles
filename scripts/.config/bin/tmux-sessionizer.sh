#!/usr/bin/env bash

directories=(
  # "$HOME/../../mnt/c/repos/"
  "$HOME/../../mnt/c/personal/"
  "$HOME/repos/"
  "$HOME/omnitech/"
)

history_file="$HOME/.tmux-sessionizer-history"

if [[ $# -eq 1 ]]; then
  selected=$1
else
  # Collect active tmux session names
  declare -A active_sessions
  if pgrep tmux >/dev/null 2>&1; then
    while IFS= read -r session; do
      active_sessions["$session"]=1
    done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)
  fi

  # Track the current session so it sorts to the bottom
  current_session=""
  [[ -n $TMUX ]] && current_session=$(tmux display-message -p '#S' 2>/dev/null)

  dir_has_session() {
    local name
    name=$(basename "$1" | tr . _)
    [[ -n "${active_sessions[$name]}" ]]
  }

  dir_is_current_session() {
    local name
    name=$(basename "$1" | tr . _)
    [[ -n "$current_session" ]] && [[ "$name" == "$current_session" ]]
  }

  # Discover all candidate directories
  all_dirs=()
  while IFS= read -r d; do
    all_dirs+=("$d")
  done < <(find "${directories[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

  # Build prioritized list
  declare -A seen
  prioritized=()

  deferred_current=()
  add_if_new() {
    local p="$1"
    if [[ -d "$p" ]] && [[ -z "${seen[$p]}" ]]; then
      seen["$p"]=1
      if dir_is_current_session "$p"; then
        deferred_current+=("$p")
      else
        prioritized+=("$p")
      fi
    fi
  }

  # 1. History entries that have an active session (most recent first)
  if [[ -f "$history_file" ]]; then
    while IFS= read -r path; do
      dir_has_session "$path" && add_if_new "$path"
    done <"$history_file"
  fi

  # 2. All other directories with active sessions (not yet in history)
  for d in "${all_dirs[@]}"; do
    dir_has_session "$d" && add_if_new "$d"
  done

  # 3. Remaining history entries (recent but no active session)
  if [[ -f "$history_file" ]]; then
    while IFS= read -r path; do
      add_if_new "$path"
    done <"$history_file"
  fi

  # 4. Everything else
  for d in "${all_dirs[@]}"; do
    add_if_new "$d"
  done

  # 5. Current session last — you're already there
  prioritized+=("${deferred_current[@]}")

  selected=$(printf '%s\n' "${prioritized[@]}" | fzf-tmux -p)
fi

if [[ -z $selected ]]; then
  echo "No selection made. Exiting."
  exit 0
fi

# Update history file: prepend selected, deduplicate, keep last 100
{
  tmp=$(mktemp)
  echo "$selected" >"$tmp"
  [[ -f "$history_file" ]] && grep -Fxv "$selected" "$history_file" >>"$tmp"
  head -n 100 "$tmp" >"$history_file"
  rm -f "$tmp"
} 2>/dev/null

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Start a new tmux session if tmux is not running
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$selected_name" -c "$selected" -d
  tmux send-keys -t "$selected_name" "lvim ." C-m    # window 1: lvim
  tmux new-window -t "$selected_name" -c "$selected" # window 2: shell
  tmux new-window -t "$selected_name" -c "$selected" # window 3: lazygit
  tmux send-keys -t "$selected_name" "lazygit" C-m
  tmux new-window -t "$selected_name" -c "$selected" -n "Claude" # window 4: copilot
  tmux send-keys -t "$selected_name" "claude" C-m
  tmux attach-session -t "$selected_name"
  exit 0
fi

# Create a new tmux session if it doesn't exist
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -s "$selected_name" -c "$selected" -d
  tmux send-keys -t "$selected_name" "lvim ." C-m    # window 1: lvim
  tmux new-window -t "$selected_name" -c "$selected" # window 2: shell
  tmux new-window -t "$selected_name" -c "$selected" # window 3: lazygit
  tmux send-keys -t "$selected_name" "lazygit" C-m
  tmux new-window -t "$selected_name" -c "$selected" -n "Copilot" # window 4: copilot
  tmux send-keys -t "$selected_name" "copilot" C-m
  tmux select-window -t "$selected_name":1
fi

# Switch to the tmux session
if [[ -n $TMUX ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach-session -t "$selected_name"
fi
