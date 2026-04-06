#!/usr/bin/env bash
#
# Rofi Wallpaper Picker
# A visual wallpaper selector that integrates with pywal theming
#

# Configuration
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures}"

# Supported image extensions
EXTENSIONS="jpg|jpeg|png|webp|gif|bmp"

# Function to apply wallpaper (replicates sw alias functionality)
apply_wallpaper() {
    local wallpaper="$1"
    
    # Start swww-daemon if not running
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon &
        sleep 0.5
    fi
    
    # Set wallpaper with transition
    swww img --transition-type center "$wallpaper"
    
    # Generate colors with pywal
    "$HOME/.local/bin/wal" -i "$wallpaper"
    
    # Regenerate rofi theme
    "$HOME/dotfiles/rofi/generate-rofi.sh"
    
    # Reload waybar
    killall -SIGUSR2 waybar 2>/dev/null
    
    # Reload notification daemon
    if pgrep -x swaync >/dev/null; then
        swaync-client --reload-css 2>/dev/null
    elif pgrep -x mako >/dev/null; then
        makoctl reload 2>/dev/null
    fi
    
    # Send notification
    notify-send -i "$wallpaper" "Wallpaper Applied" "$(basename "$wallpaper")" -t 2000
}

# Function to get wallpapers (excludes Screenshots, Camera, etc.)
get_wallpapers() {
    find "$WALLPAPER_DIR" -maxdepth 2 -type f \
        -regextype posix-extended \
        -regex ".*\.($EXTENSIONS)" \
        ! -path "*/Screenshots/*" \
        ! -path "*/Camera/*" \
        2>/dev/null | sort
}

# Build rofi menu entries - use original images directly (rofi scales them)
build_menu() {
    while IFS= read -r img; do
        filename=$(basename "$img")
        # Use the original image as icon - rofi will scale it
        printf '%s\0icon\x1f%s\n' "$filename" "$img"
    done < <(get_wallpapers)
}

# Main
main() {
    # Check for required tools
    if ! command -v rofi &>/dev/null; then
        notify-send "Error" "rofi is not installed" -u critical
        exit 1
    fi
    
    if ! command -v swww &>/dev/null; then
        notify-send "Error" "swww is not installed" -u critical
        exit 1
    fi
    
    # Get wallpapers list
    mapfile -t wallpapers < <(get_wallpapers)
    
    # Exit if no wallpapers found
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR" -u warning
        exit 1
    fi
    
    # Show rofi menu
    selected=$(build_menu | rofi -dmenu \
        -theme "$HOME/dotfiles/rofi/wallpaper-picker.rasi" \
        -p "" \
        -show-icons \
        -i \
        -format 'i' \
        -selected-row 0)
    
    # Exit if nothing selected
    [[ -z "$selected" ]] && exit 0
    
    # Get the selected wallpaper path
    wallpaper="${wallpapers[$selected]}"
    
    if [[ -f "$wallpaper" ]]; then
        apply_wallpaper "$wallpaper"
    else
        notify-send "Error" "Wallpaper not found: $wallpaper" -u critical
        exit 1
    fi
}

# Handle arguments
case "${1:-}" in
    --random)
        mapfile -t wallpapers < <(get_wallpapers)
        if [[ ${#wallpapers[@]} -gt 0 ]]; then
            random_idx=$((RANDOM % ${#wallpapers[@]}))
            apply_wallpaper "${wallpapers[$random_idx]}"
        fi
        exit 0
        ;;
    --next|--prev)
        # Get current wallpaper from pywal cache
        current=$(grep -oP '(?<=\$wallpaper = ).*' ~/.cache/wal/colors-hyprland.conf 2>/dev/null)
        mapfile -t wallpapers < <(get_wallpapers)
        
        if [[ ${#wallpapers[@]} -gt 0 ]]; then
            # Find current index
            current_idx=-1
            for i in "${!wallpapers[@]}"; do
                if [[ "${wallpapers[$i]}" == "$current" ]]; then
                    current_idx=$i
                    break
                fi
            done
            
            # Calculate next/prev index
            if [[ "$1" == "--next" ]]; then
                next_idx=$(( (current_idx + 1) % ${#wallpapers[@]} ))
            else
                next_idx=$(( (current_idx - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
            fi
            
            apply_wallpaper "${wallpapers[$next_idx]}"
        fi
        exit 0
        ;;
    --help|-h)
        echo "Usage: $(basename "$0") [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --random       Apply a random wallpaper"
        echo "  --next         Apply next wallpaper in list"
        echo "  --prev         Apply previous wallpaper in list"
        echo "  --help         Show this help message"
        echo ""
        echo "Environment variables:"
        echo "  WALLPAPER_DIR  Directory to search for wallpapers (default: ~/Pictures)"
        exit 0
        ;;
    *)
        main
        ;;
esac
