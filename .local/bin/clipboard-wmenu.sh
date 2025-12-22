#!/bin/sh
# 1. Get history from cliphist
# 2. Pipe into wmenu (using your colors)
# 3. Decode the selection and copy it back to clipboard

cliphist list | wmenu -f "JetBrainsMono Nerd Font 10" -l 10 -p "Clipboard:" \
  -N '#121222' -n '#dcdcdc' -M '#121222' -m '#00ff99' -S '#00ff99' -s '#121222' | \
  cliphist decode | wl-copy
