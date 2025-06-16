#!/bin/sh

INTERVAL=1800 # time in seconds to change
WALLPAPERS_DIR="$HOME/Pictures/wallpapers"
LAST_WALLPAPER=""

while true; do
  wallpaper_path=$(find "$WALLPAPERS_DIR" -type f \( -iname "*.jpeg" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.svg" \) | shuf -n1)

  # Skip if same as last wallpaper
  if [ "$wallpaper_path" = "$LAST_WALLPAPER" ]; then
    sleep 1
    continue
  fi

  swww img "$wallpaper_path" --transition-fps 60 --transition-type wipe

  # Only run wal if wallpaper actually changed
  wal -qi "$wallpaper_path"
  LAST_WALLPAPER="$wallpaper_path"
  cp "$wallpaper_path" /tmp/lockscreen_background

  ~/.local/bin/update-ghostty-wal-colors.sh

  sleep "$INTERVAL"
done
