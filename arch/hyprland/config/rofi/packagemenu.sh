#!/bin/bash

# -----------------------------------------------------------------------------
# Package Management Menu (Floating Terminal Version)
# -----------------------------------------------------------------------------

set -euo pipefail

# Configuration
SCRIPTS_DIR="$HOME/scripts"
ROFI_MSG="Package Manager"
# Title used by Hyprland to catch the window and make it float
WIN_TITLE="floating-window"

# Define the menu options
declare -A menu_actions
menu_actions=(
    ["󰏔   Install Package"]="${SCRIPTS_DIR}/helper-install-package"
    ["󰣇   Install AUR"]="${SCRIPTS_DIR}/helper-install-aur"
    ["󰆴   Remove Package"]="${SCRIPTS_DIR}/helper-remove-package"
)

menu_order=(
    "󰏔   Install Package"
    "󰣇   Install AUR"
    "󰆴   Remove Package"
)

# 1. Generate the list of options for Rofi
rofi_options=$(printf "%s\n" "${menu_order[@]}")

# 2. Launch Rofi
selected_option=$(echo -e "$rofi_options" | rofi -dmenu -i -p "$ROFI_MSG")

# 3. Execution
if [[ -n "$selected_option" ]] && [[ -v "menu_actions[$selected_option]" ]]; then
    command_to_run="${menu_actions[$selected_option]}"
    
    # Launch in a terminal, set title for floating rule, 
    $TERMINAL --title "$WIN_TITLE" sh -c "$command_to_run;"
else
    exit 0
fi