#!/bin/sh
# One full-width bar per monitor, shared by XMonad and theme restarts.
set -eu
screen=${1:?screen number required}
case "$screen" in
  0) xpos=1920 ;;
  1) xpos=0 ;;
  *) exit 2 ;;
esac
bar_runtime="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR must be set}/xmobar"
mkdir -p "$bar_runtime"
display_key=$(printf '%s' "${DISPLAY:-:0}" | tr -c '[:alnum:]' '_')
# The supervisor holds the lock; --close prevents click-launched apps from
# inheriting it and blocking future bar restarts.
export XMOBAR_SCREEN="$screen"
exec flock -n --close "$bar_runtime/$display_key-screen-$screen.lock" \
  xmobar -x "$screen" \
  -p "Static { xpos = $xpos, ypos = 0, width = 1920, height = 24 }" \
  "$HOME/.config/xmobar/xmobarrc" \
  </dev/null >"$bar_runtime/screen-$screen.log" 2>&1
