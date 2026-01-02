#!/bin/bash

# -----------------------------------------------------------------------------
# Power Menu Script
# Dependencies: rofi
# -----------------------------------------------------------------------------

# Safety: Exit on error, unset variables, or pipe failures
set -euo pipefail

# Configuration
SCRIPTS_DIR="$HOME/scripts"
ROFI_MSG="Power Menu"

# Define the menu options as an associative array (Key = Display, Value = Command)
# We use spaces in the keys to fix the "icon too close to text" issue.
declare -A menu_actions
menu_actions=(
    ["󰌾   Lock"]="${SCRIPTS_DIR}/helper-lock-screen"
    ["󰍃   Logout"]="${SCRIPTS_DIR}/helper-logout"
    ["󰒲   Suspend"]="${SCRIPTS_DIR}/helper-suspend"
    ["󰜉   Reboot"]="${SCRIPTS_DIR}/helper-reboot"
    ["󰐥   Shutdown"]="${SCRIPTS_DIR}/helper-shutdown"
)

# Define the order of appearance (Associative arrays do not preserve order)
menu_order=(
    "󰌾   Lock"
    "󰍃   Logout"
    "󰒲   Suspend"
    "󰜉   Reboot"
    "󰐥   Shutdown"
)

# -----------------------------------------------------------------------------
# Logic
# -----------------------------------------------------------------------------

# 1. Generate the list of options for Rofi
# We join the array elements with newlines
rofi_options=$(printf "%s\n" "${menu_order[@]}")

# 2. Launch Rofi and capture the selection
# -i: Case insensitive
# -p: Prompt
selected_option=$(echo -e "$rofi_options" | rofi -dmenu -i -p "$ROFI_MSG")

# 3. Validation and Execution
# Check if the user selected an option and if that option exists in our map
if [[ -n "$selected_option" ]] && [[ -v "menu_actions[$selected_option]" ]]; then
    command_to_run="${menu_actions[$selected_option]}"
    
    # Optional: Notify user (useful for debugging or confirmation)
    # echo "Executing: $command_to_run"

    # Execute the command
    # We use 'eval' or direct execution. Since these are scripts, direct is safer.
    "$command_to_run"
else
    # Handle cases where user presses Esc or closes the window
    exit 0
fi