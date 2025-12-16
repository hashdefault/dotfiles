#!/bin/sh
# 1. Get history from cliphist
# 2. Pipe into wmenu (using your colors)
# 3. Decode the selection and copy it back to clipboard

cliphist list | wmenu -f "JetBrainsMono Nerd Font 10" -l 10 -p "Clipboard:" \
    -N '#1e1e2e' -n '#cdd6f4' -M '#1e1e2e' -m '#cba6f7' -S '#cba6f7' -s '#1e1e2e' | \
    cliphist decode | wl-copy
