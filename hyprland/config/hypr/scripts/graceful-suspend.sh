#!/bin/bash
# Lock first, then suspend
hyprlock &

# Optional: close windows before suspend (helps some apps save state)
HYPRCMDS=$(hyprctl clients -j | jq -j '.[] | "dispatch closewindow address:\(.address); "')
[[ -n "$HYPRCMDS" ]] && hyprctl --batch "$HYPRCMDS"

# Small delay to let apps save state (e.g., browser sessions)
sleep 1.5

systemctl suspend