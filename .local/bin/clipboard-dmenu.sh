#!/bin/sh
# 1. Get history from cliphist
# 2. Pipe into dmenu (using your colors)
# 3. Decode the selection and copy it back to clipboard


selected=$(cliphist list | sed 's/^[^\t]*\t//' | dmenu -fn "JetBrainsMono Nerd Font:size=10" -l 10 -p "Clipboard:" \
  -nb '#121222' -nf '#dcdcdc' -sb '#00ff99' -sf '#121222')

if [ -n "$selected" ]; then
    cliphist list | grep -F "$selected" | head -n1 | cliphist decode | wl-copy
fi
