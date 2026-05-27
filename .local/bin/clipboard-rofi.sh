#!/usr/bin/env bash
set -euo pipefail

# 1. Start the clipboard daemons if they aren't already running
# cliphist requires wl-paste to feed it data
if ! pgrep -x "wl-paste" >/dev/null; then
    # Watch for text selections
    wl-paste --type text --watch cliphist store &
    # Watch for image/binary selections (optional but highly recommended)
    wl-paste --type image --watch cliphist store &
fi

# 2. Launch the rofi picker
# cliphist list outputs the history -> rofi handles selection -> cliphist decode copies it back
cliphist list | rofi -dmenu -i -p "󰅍 clipboard" | cliphist decode | wl-copy
