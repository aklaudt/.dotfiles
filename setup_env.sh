#!/usr/bin/env bash

# Stops immediately on any error or undefined variable
set -euo pipefail

# Resolve the directory this script lives in
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Defaults
filter=""
dry_run=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry)
            dry_run=true
            ;;
        *)
            filter="$1"
            ;;
    esac
    shift
done

# Logging helper
log() {
    if $dry_run; then
        echo "[DRY_RUN] $1"
    else
        echo "$1"
    fi
}

log "RUN: filter='$filter'"

# Find executable files in jobs/
mapfile -t run_scripts < <(find "$script_dir/jobs" -mindepth 1 -maxdepth 1 -type f -perm -111 | sort)

for script in "${run_scripts[@]}"; do
    name="$(basename "$script")"

    # Apply optional filter
    if [[ -n "$filter" && ! "$name" =~ $filter ]]; then
        log "Filtered out: $name (did not match '$filter')"
        continue
    fi

    log "Running: $name"

    if ! $dry_run; then
        "$script" || { echo "Error: $name failed — aborting."; exit 1; }
    fi
done

