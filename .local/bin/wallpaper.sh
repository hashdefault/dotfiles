#!/bin/sh
WALLPAPERS_DIR="$HOME/Pictures/wallpapers"

while true; do
    swww img "$(find "$WALLPAPERS_DIR" -type f | shuf -n1)" --transition-fps 60 --transition-type wipe
    sleep 900  # Change wallpaper every 5 minutes
done
