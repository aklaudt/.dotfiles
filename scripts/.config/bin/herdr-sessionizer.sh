#!/usr/bin/env bash
# herdr port of tmux-sessionizer.sh.
# A tmux session becomes a herdr workspace; the four tmux windows become tabs.

directories=(
  # "$HOME/../../mnt/c/repos/"
  "$HOME/../../mnt/c/personal/"
  "$HOME/repos/"
  "$HOME/omnitech/"
  "$HOME/sandbox/"
)

history_file="$HOME/.herdr-sessionizer-history"

workspace_name() {
  basename "$1" | tr . _
}

# label -> workspace_id for every live workspace
declare -A workspace_ids
while IFS=$'\t' read -r label id; do
  [[ -n $label ]] && workspace_ids["$label"]=$id
done < <(herdr workspace list 2>/dev/null |
  jq -r '.result.workspaces[] | [.label, .workspace_id] | @tsv')

current_workspace=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}

if [[ $# -eq 1 ]]; then
  selected=$1
else
  dir_has_workspace() {
    [[ -n "${workspace_ids[$(workspace_name "$1")]:-}" ]]
  }

  dir_is_current_workspace() {
    local id="${workspace_ids[$(workspace_name "$1")]:-}"
    [[ -n $current_workspace ]] && [[ "$id" == "$current_workspace" ]]
  }

  # Discover all candidate directories
  all_dirs=()
  while IFS= read -r d; do
    all_dirs+=("$d")
  done < <(find "${directories[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  all_dirs+=("$HOME/.dotfiles")

  # Build prioritized list
  declare -A seen
  prioritized=()

  deferred_current=()
  add_if_new() {
    local p="$1"
    if [[ -d "$p" ]] && [[ -z "${seen[$p]:-}" ]]; then
      seen["$p"]=1
      if dir_is_current_workspace "$p"; then
        deferred_current+=("$p")
      else
        prioritized+=("$p")
      fi
    fi
  }

  # 1. History entries that have a live workspace (most recent first)
  if [[ -f "$history_file" ]]; then
    while IFS= read -r path; do
      dir_has_workspace "$path" && add_if_new "$path"
    done <"$history_file"
  fi

  # 2. All other directories with live workspaces (not yet in history)
  for d in "${all_dirs[@]}"; do
    dir_has_workspace "$d" && add_if_new "$d"
  done

  # 3. Remaining history entries (recent but no live workspace)
  if [[ -f "$history_file" ]]; then
    while IFS= read -r path; do
      add_if_new "$path"
    done <"$history_file"
  fi

  # 4. Everything else
  for d in "${all_dirs[@]}"; do
    add_if_new "$d"
  done

  # 5. Current workspace last — you're already there
  prioritized+=("${deferred_current[@]}")

  selected=$(printf '%s\n' "${prioritized[@]}" | fzf --height 100%)
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

selected_name=$(workspace_name "$selected")

# Switch to the workspace if it already exists
existing=${workspace_ids[$selected_name]:-}
if [[ -n $existing ]]; then
  herdr workspace focus "$existing" >/dev/null
  exit 0
fi

# Otherwise build it: tab 1 lvim, tab 2 shell, tab 3 lazygit, tab 4 claude
created=$(herdr workspace create --cwd "$selected" --label "$selected_name" --focus)
workspace=$(jq -r '.result.workspace.workspace_id' <<<"$created")
editor_tab=$(jq -r '.result.tab.tab_id' <<<"$created")
editor_pane=$(jq -r '.result.root_pane.pane_id' <<<"$created")

herdr tab rename "$editor_tab" editor >/dev/null
herdr pane run "$editor_pane" "lvim ." >/dev/null

new_tab() { # label [command]
  local label=$1 command=${2:-} pane
  pane=$(herdr tab create --workspace "$workspace" --cwd "$selected" --label "$label" --no-focus |
    jq -r '.result.root_pane.pane_id')
  [[ -n $command ]] && herdr pane run "$pane" "$command" >/dev/null
}

new_tab shell
new_tab git lazygit
# herdr detects `claude` on its own and tracks its state in the sidebar. Use
# `herdr agent start <name> --kind claude --pane <id>` instead if you want a
# stable name to drive the agent from the CLI.
new_tab claude claude

herdr tab focus "$editor_tab" >/dev/null
