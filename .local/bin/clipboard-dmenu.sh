#!/bin/sh
# 1. Get history from greenclip
# 2. Pipe into dmenu (using your colors)
# 3. Copy the selection back to clipboard

selected=$(greenclip print | dmenu -fn "JetBrainsMono Nerd Font:size=10" -l 10 -p "Clipboard:" \
  -nb '#121222' -nf '#dcdcdc' -sb '#00ff99' -sf '#121222')

if [ -n "$selected" ]; then
    greenclip print "$selected"
fi
