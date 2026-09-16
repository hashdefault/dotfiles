#!/usr/bin/env bash
# Kills and respawns both xmobar instances. Used by the theme-chooser after
# regenerating xmobarrc (xmobar has no live config-reload, unlike kitty/
# alacritty/eww), and safe to run any time xmobar needs a kick.
#
# Geometry and per-screen instance locks live in start-xmobar.sh, also used
# by XMonad. CommandReader's tray watchers exit when their bar closes.

bar_log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/xmobar"
mkdir -p "$bar_log_dir"
pkill -u "$(id -u)" -x xmobar 2>/dev/null
sleep 0.3

# Both windows span the monitor; tray-padding.py reserves content space.
nohup "$HOME/.config/xmonad/scripts/start-xmobar.sh" 0 </dev/null >"$bar_log_dir/launch-0.log" 2>&1 &
nohup "$HOME/.config/xmonad/scripts/start-xmobar.sh" 1 </dev/null >"$bar_log_dir/launch-1.log" 2>&1 &
