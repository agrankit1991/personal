#!/bin/bash
# Close all windows gracefully
HYPRCMDS=$(hyprctl clients -j | jq -j '.[] | "dispatch closewindow address:\(.address); "')
[[ -n "$HYPRCMDS" ]] && hyprctl --batch "$HYPRCMDS"

# Small delay to let apps save state (e.g., browser sessions)
sleep 1.5

hyprctl dispatch exit