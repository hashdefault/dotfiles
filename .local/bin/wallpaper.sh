#!/bin/sh

INTERVAL=1800 # time in seconds to change

WALLPAPERS_DIR="$HOME/Pictures/wallpapers"

while true; do
  RESPONSE=$(swww img "$(find "$WALLPAPERS_DIR" -type f | shuf -n1)" --transition-fps 60 --transition-type wipe 2>&1)
  if echo $RESPONSE | grep -iq "Error"; then
    continue
  fi

  sleep "$INTERVAL"
done
