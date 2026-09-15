#!/usr/bin/env bash
# Keeps `xset r rate 200 35` applied for the whole session.
#
# The X server resets autorepeat to its 660/25 default for every keyboard it
# (re-)adds, and it re-adds all input devices whenever udev re-announces them:
# screen lock/DPMS, suspend/resume, USB reconnects, package updates that run
# `udevadm trigger`. Confirmed in /var/log/Xorg.0.log: a burst of
# "config/udev: removing device ... Keychron K2" + "Adding input device" with
# nothing else in the session touching the keyboard, after which `xset q`
# showed 660/25 again.
#
# Applies the rate right away (so every xmonad startup/restart still sets it),
# then -- single-instance, flock-guarded like forecast-updater.sh -- watches
# udev input "add" events and re-applies once each burst settles. Runs as the
# user: `udevadm monitor` needs no root, and xinput isn't installed.
#
# The proper server-side fix is `Option "AutoRepeat" "200 35"` in an Xorg
# InputClass (/etc/X11/xorg.conf.d/01-keyboard-repeat.conf); this script is
# the no-root fallback and is harmless alongside it.

apply() { xset r rate 200 35; }

apply

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/xmonad-keyboard-repeat.lock"
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  # Another watcher is already running (e.g. across `xmonad --restart`)
  exit 0
fi

udevadm monitor --udev --subsystem-match=input 2>/dev/null |
  while read -r line; do
    case "$line" in
      *" add "*) ;;
      *) continue ;;
    esac
    # A re-add comes as a burst of events, and X only picks each device up
    # after udev finishes -- drain until 1s of quiet, then apply once.
    while read -r -t 1 _; do :; done
    apply
  done
