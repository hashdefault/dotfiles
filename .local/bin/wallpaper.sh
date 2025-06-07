#!/bin/sh

INTERVAL=1800 # time in seconds to change

WALLPAPERS_DIR="$HOME/Pictures/wallpapers"

while true; do

  wallpaper_path=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpeg" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.svg" \) | shuf -n1)
  swww img $wallpaper_path --transition-fps 60 --transition-type wipe 2>&1

  sleep 2
  wal -qi $wallpaper_path

  sleep "$INTERVAL"
done
