#!/usr/bin/env bash
# CPU and memory for the herdr tab bar, replacing @powerkit_plugins 'cpu,memory'.
# Git branch/status already render in the sidebar space rows.
set -euo pipefail

read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
busy=$((user + nice + system + irq + softirq + steal))
total=$((busy + idle + iowait))

sleep 0.25

read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
busy2=$((user + nice + system + irq + softirq + steal))
total2=$((busy2 + idle + iowait))

cpu=0
(( total2 > total )) && cpu=$(((busy2 - busy) * 100 / (total2 - total)))

mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", (t-a)*100/t}' /proc/meminfo)

printf 'cpu %d%% mem %d%%\n' "$cpu" "$mem"
