#!/bin/bash

# Options for the menu
options="󰌾 Lock\n󰍃 Logout\n󰒲 Suspend\n󰜉 Reboot\n󰐥 Shutdown"

# Show the Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Execute based on choice
case $chosen in
"󰌾 Lock")
  ~/.config/hypr/scripts/graceful-lock.sh
  ;;
"󰍃 Logout")
  ~/.config/hypr/scripts/graceful-logout.sh
  ;;
"󰒲 Suspend")
  ~/.config/hypr/scripts/graceful-suspend.sh
  ;;
"󰐥 Shutdown")
  ~/.config/hypr/scripts/graceful-shutdown.sh
  ;;
"󰜉 Reboot")
  ~/.config/hypr/scripts/graceful-reboot.sh
  ;;
esac
