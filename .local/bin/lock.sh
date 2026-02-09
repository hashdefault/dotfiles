#!/bin/bash

WALLPAPER_DIR=~/Pictures/wallpapers/

lock() {
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) | shuf -n 1)
    betterlockscreen -u "$WALLPAPER"
    betterlockscreen -l
}

warn() {
    dunstify -u critical -t 30000 "Screen Lock" "Locking in 30 seconds..."
}

case "$1" in
    --lock)
        lock
        ;;
    --warn)
        warn
        ;;
    *)
        # Kill any existing xautolock instance
        killall xautolock 2>/dev/null

        xautolock \
            -time 15 \
            -locker "$0 --lock" \
            -notify 30 \
            -notifier "$0 --warn" \
            -detectsleep &

        echo "Idle lock daemon started (locks after 15min, warns 30s before)"
        ;;
esac
