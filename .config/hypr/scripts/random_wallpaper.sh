#!/bin/bash

# Define the directory containing your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Find a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [ -n "$RANDOM_WALLPAPER" ]; then
    # Preload the new wallpaper
    hyprctl hyprpaper preload "$RANDOM_WALLPAPER"

    # Get list of connected monitors using hyprctl and jq
    MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

    # Loop through each monitor and set the same wallpaper
    for MONITOR in $MONITORS; do
        hyprctl hyprpaper wallpaper "$MONITOR,$RANDOM_WALLPAPER"
    done

    # Unload unused wallpapers to save memory
    # 'unload all' unloads all wallpapers that are NOT currently displayed
    hyprctl hyprpaper unload all
else
    echo "No wallpapers found in $WALLPAPER_DIR"
fi