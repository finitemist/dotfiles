#!/bin/bash

# Function to get and print current layout
get_layout() {
    layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')
    if [[ "$layout" == "English (US)" ]]; then
        echo '{"text": " EN", "tooltip": "English (US)"}'
    elif [[ "$layout" == "Arabic" ]]; then
        echo '{"text": " AR", "tooltip": "Arabic"}'
    else
        echo "{\"text\": \" $layout\", \"tooltip\": \"$layout\"}"
    fi
}

# Print initial layout
get_layout

# Listen to Hyprland socket for layout changes
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    if [[ $line == *"activelayout"* ]]; then
        get_layout
    fi
done
