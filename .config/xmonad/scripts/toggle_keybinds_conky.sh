#!/usr/bin/env bash

CFG="$HOME/.config/xmonad/scripts/conky_keybinds.conf"

# Toggle Conky keybind guide
if pgrep -f "conky.*$CFG" >/dev/null 2>&1; then
  pkill -f "conky.*$CFG"
else
  nohup conky -c "$CFG" >/dev/null 2>&1 &
fi

