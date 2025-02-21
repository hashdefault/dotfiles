#!/bin/sh

WALLPAPERS_DIR="$HOME/Pictures/wallpapers"

swww img "$(find "$WALLPAPERS_DIR" -type f | shuf -n1)" --transition-fps 60 --transition-type wipe
