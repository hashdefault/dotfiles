#!/usr/bin/env bash
# Kills and respawns both xmobar instances. Used by the theme-chooser after
# regenerating xmobarrc (xmobar has no live config-reload, unlike kitty/
# alacritty/eww), and safe to run any time xmobar needs a kick.
#
# Position values here (xpos/width per screen) must stay in sync with
# xmonad.hs's myScreenXOffset/myBarWidth/myTrayerLaneWidth -- they're
# duplicated here only because xmonad.hs's own spawnOnce calls never
# re-fire after xmonad --restart, so the theme-chooser can't just ask
# xmonad to redo it.

pkill -f "xmobar -x" 2>/dev/null
sleep 0.3

env XMOBAR_SCREEN=0 xmobar -x 0 -p "Static { xpos = 1920, ypos = 0, width = 1765, height = 24 }" "$HOME/.config/xmobar/xmobarrc" &disown
env XMOBAR_SCREEN=1 xmobar -x 1 -p "Static { xpos = 0, ypos = 0, width = 1920, height = 24 }" "$HOME/.config/xmobar/xmobarrc" &disown
