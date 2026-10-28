#!/usr/bin/env bash
# Focus the Nth tab (1-based) of the active herdr workspace.
# herdr only exposes indexed tab switching as a single prefix+1..9 block, so the
# home-row bindings (prefix + u/i/o/p) route through the socket API instead.
set -euo pipefail

index=${1:?usage: herdr-goto-tab.sh <tab-index>}

workspace=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}
if [[ -z $workspace ]]; then
  echo "No active herdr workspace." >&2
  exit 1
fi

tab=$(herdr tab list --workspace "$workspace" |
  jq -r --argjson i "$index" '[.result.tabs[].tab_id][$i - 1] // empty')

# Silently do nothing when the workspace has fewer tabs, like tmux's select-window.
[[ -n $tab ]] || exit 0

herdr tab focus "$tab" >/dev/null
