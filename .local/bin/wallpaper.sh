#!/bin/sh

set -eu

# Configurable via environment
: "${INTERVAL:=1800}" # seconds between changes
: "${WALLPAPERS_DIR:="$HOME/Pictures/wallpapers"}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
LAST_FILE="$CACHE_DIR/wallpaper-last"
LAST_WALLPAPER=""

mkdir -p "$CACHE_DIR"

# Load last wallpaper if persisted
if [ -f "$LAST_FILE" ]; then
  if LAST_WALLPAPER_CONTENT=$(cat "$LAST_FILE" 2>/dev/null); then
    LAST_WALLPAPER="$LAST_WALLPAPER_CONTENT"
  fi
fi

ensure_swww() {
  if pgrep -x swww-daemon >/dev/null 2>&1; then
    return 0
  fi
  # Try to start swww daemon
  swww init >/dev/null 2>&1 || true
  # Wait up to ~5 seconds for readiness
  i=0
  while [ $i -lt 5 ]; do
    if swww query >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done
  return 1
}

has_images() {
  [ -d "$WALLPAPERS_DIR" ] || return 1
  find "$WALLPAPERS_DIR" -type f \( -iname "*.jpeg" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.svg" \) -print -quit | grep -q .
}

pick_random() {
  find "$WALLPAPERS_DIR" -type f \( -iname "*.jpeg" -o -iname "*.jpg" -o -iname "*.png" -o -iname "*.svg" \) -print0 \
    | shuf -z -n1 | tr -d '\0'
}

# Ensure swww is available at start (will retry later if not)
if ! ensure_swww; then
  echo "warning: swww not available; will retry each cycle" >&2
fi

while true; do
  # Guard: no images or directory missing
  if ! has_images; then
    echo "warning: No images found in $WALLPAPERS_DIR; retrying in 60s" >&2
    sleep 60
    continue
  fi

  wallpaper_path="$(pick_random || true)"

  # Guard: failed to pick any file
  if [ -z "${wallpaper_path:-}" ]; then
    echo "warning: Failed to select a wallpaper; retrying in 10s" >&2
    sleep 10
    continue
  fi

  # Skip if same as last wallpaper (persisted across runs)
  if [ "$wallpaper_path" = "${LAST_WALLPAPER:-}" ]; then
    sleep 1
    continue
  fi

  # Ensure swww is running before setting the image
  if ! ensure_swww; then
    echo "warning: swww not running; skipping this cycle" >&2
    sleep "$INTERVAL"
    continue
  fi

  swww img "$wallpaper_path" --transition-fps 60 --transition-type wipe || {
    echo "warning: swww failed to set image" >&2
  }

  # Only run wal if wallpaper actually changed
  wal -qi "$wallpaper_path" || true
  LAST_WALLPAPER="$wallpaper_path"
  printf '%s\n' "$LAST_WALLPAPER" > "$LAST_FILE" || true
  cp -f "$wallpaper_path" /tmp/lockscreen_background 2>/dev/null || true

  [ -x "$HOME/.local/bin/update-ghostty-wal-colors.sh" ] && "$HOME/.local/bin/update-ghostty-wal-colors.sh" || true

  sleep "$INTERVAL"
done
