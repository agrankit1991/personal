#!/bin/bash

set -e

# Function to find the HDMI card (the one with available HDMI stereo outputs)
find_hdmi_card() {
    pactl list cards | awk '
    BEGIN { current_card = "" }
    /^Card #/ { current_card = ""; next }
    /^[[:space:]]*Name: / { current_card = $2; next }
    /^[[:space:]]*output:hdmi-stereo(-extra[0-9]+)?: / && /available: yes/ {
        if (current_card != "") {
            hdmi_cards[current_card] = 1
        }
    }
    END {
        for (c in hdmi_cards) {
            print c
            exit
        }
    }'
}

# Find analog sink (the one containing "analog-stereo")
ANALOG_SINK=$(pactl list sinks short | awk '/analog-stereo/ {print $2; exit}')

# Find HDMI card name
HDMI_CARD=$(find_hdmi_card)

if [ -z "$HDMI_CARD" ]; then
    notify-send " Audio Switcher" "No HDMI audio card detected!"
    exit 1
fi

# Extract available HDMI stereo profiles with their human-readable descriptions
HDMI_PROFILES=$(pactl list cards | awk -v card="$HDMI_CARD" '
BEGIN { found = 0 }
/^[[:space:]]*Name: / { found = ($2 == card) }
found && /^[[:space:]]*output:hdmi-stereo(-extra[0-9]+)?: / {
    profile = $1
    sub(/:$/, "", profile)
    
    # First, remove the details part
    temp = $0
    sub(/ \(sinks:.*\)/, "", temp)
    
    # Then, extract desc after the second colon
    desc = temp
    sub(/^[^:]*:[^:]*: */, "", desc)
    
    if (index($0, "available: yes") > 0) {
        print profile "|" desc
    }
}
')

# Build rofi menu (single-line entries)
MENU_OPTIONS=""

if [ -n "$ANALOG_SINK" ]; then
    MENU_OPTIONS+="󰋋 Built-in Audio (Analog) | $ANALOG_SINK\n"
fi

while IFS='|' read -r profile desc; do
    [ -z "$profile" ] && continue
    
    # Clean up description for display
    display_name=$(echo "$desc" | sed -e 's/ Output$//' -e 's/Digital Stereo (HDMI)/HDMI/' -e 's/Digital Stereo (HDMI \([0-9]\))/HDMI \1/')
    
    MENU_OPTIONS+="󰍹 $display_name | $profile\n"
done <<< "$HDMI_PROFILES"

# Show menu with rofi
CHOICE=$(echo -e "$MENU_OPTIONS" | sed '/^$/d' | \
    rofi -dmenu -i -p "🔊 Select Audio Output" \
         -theme-str 'window {width: 500px;} listview {lines: 10;}')

[ -z "$CHOICE" ] && exit 0

# Extract selected profile or sink
SELECTED=$(echo "$CHOICE" | awk -F' \\| ' '{print $2}')

# Extract display name for notification (trim icon and spaces)
DISPLAY_NAME=$(echo "$CHOICE" | awk -F' \\| ' '{print $1}' | sed 's/^[ 󰍹 󰋋]*//')

if [[ "$SELECTED" == "$ANALOG_SINK" ]]; then
    pactl set-default-sink "$ANALOG_SINK"
    notify-send " Audio Output" "Switched to Built-in Audio (Analog)"
else
    # Switch card profile to selected HDMI output
    pactl set-card-profile "$HDMI_CARD" "$SELECTED"
    
    # Wait briefly for the new sink to appear
    sleep 0.3
    
    # Find the newly activated HDMI sink (first one)
    NEW_SINK=$(pactl list sinks short | awk '/hdmi/ {print $2; exit}')
    
    if [ -n "$NEW_SINK" ]; then
        pactl set-default-sink "$NEW_SINK"
    fi
    
    notify-send " Audio Output" "Switched to $DISPLAY_NAME"
fi

# Move all existing streams to the new default sink
pactl list sink-inputs short | awk '{print $1}' | \
    xargs -r -I{} pactl move-sink-input {} @DEFAULT_SINK@