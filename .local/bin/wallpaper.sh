#!/bin/sh

set -eu

: "${INTERVAL:=1800}"
: "${WALLPAPERS_DIR:="$HOME/Pictures/wallpapers"}"
: "${SWWW_TRANSITION_TYPE:=wipe}"
: "${SWWW_TRANSITION_FPS:=60}"
: "${SWWW_TRANSITION_DURATION:=1.2}"
: "${SWWW_RESIZE:=crop}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
LAST_FILE="$CACHE_DIR/wallpaper-last"
BACKEND_FILE="$CACHE_DIR/wallpaper-backend"
SWAYBG_PID_FILE="$CACHE_DIR/wallpaper-swaybg.pid"
LAST_WALLPAPER=""

mkdir -p "$CACHE_DIR"

if [ -f "$LAST_FILE" ]; then
  LAST_WALLPAPER=$(cat "$LAST_FILE" 2>/dev/null || printf '')
fi

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

image_files() {
  find "$WALLPAPERS_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tif" -o -iname "*.tiff" \) \
    "$@"
}

has_images() {
  [ -d "$WALLPAPERS_DIR" ] || return 1
  image_files -print -quit | grep -q .
}

pick_random() {
  image_files -print0 | shuf -z -n 1 | tr -d '\0'
}

write_backend() {
  if ! printf '%s\n' "$1" | tee "$BACKEND_FILE" >/dev/null 2>&1; then
    :
  fi
}

write_cache_file() {
  target=$1
  value=$2

  if ! printf '%s\n' "$value" | tee "$target" >/dev/null 2>&1; then
    :
  fi
}

start_swww_daemon() {
  if ! have_cmd swww; then
    return 1
  fi

  if swww query >/dev/null 2>&1; then
    write_backend swww
    return 0
  fi

  if have_cmd swww-daemon; then
    swww-daemon >/dev/null 2>&1 &
  else
    swww init >/dev/null 2>&1 || true
  fi

  i=0
  while [ "$i" -lt 10 ]; do
    if swww query >/dev/null 2>&1; then
      write_backend swww
      return 0
    fi
    sleep 1
    i=$((i + 1))
  done

  return 1
}

start_swaybg() {
  have_cmd swaybg || return 1

  if [ -f "$SWAYBG_PID_FILE" ]; then
    old_pid=$(cat "$SWAYBG_PID_FILE" 2>/dev/null || printf '')
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      kill "$old_pid" 2>/dev/null || true
      wait "$old_pid" 2>/dev/null || true
    fi
  fi

  swaybg -i "$1" -m fill >/dev/null 2>&1 &
  write_cache_file "$SWAYBG_PID_FILE" "$!"
  write_backend swaybg
}

ensure_backend() {
  start_swww_daemon && return 0

  if have_cmd swaybg; then
    write_backend swaybg
    return 0
  fi

  return 1
}

apply_wallpaper() {
  wallpaper_path=$1

  if start_swww_daemon; then
    swww img "$wallpaper_path" \
      --transition-type "$SWWW_TRANSITION_TYPE" \
      --transition-fps "$SWWW_TRANSITION_FPS" \
      --transition-duration "$SWWW_TRANSITION_DURATION" \
      --resize "$SWWW_RESIZE"
    return 0
  fi

  if have_cmd swaybg; then
    start_swaybg "$wallpaper_path"
    return 0
  fi

  return 1
}

post_apply() {
  wallpaper_path=$1

  if have_cmd wal; then
    wal -qi "$wallpaper_path" || true
  fi

  LAST_WALLPAPER="$wallpaper_path"
  write_cache_file "$LAST_FILE" "$LAST_WALLPAPER"
  cp -f "$wallpaper_path" /tmp/lockscreen_background 2>/dev/null || true

}

if ! ensure_backend; then
  echo "warning: no wallpaper backend found; install swww or swaybg" >&2
fi

while true; do
  if ! has_images; then
    echo "warning: no images found in $WALLPAPERS_DIR; retrying in 60s" >&2
    sleep 60
    continue
  fi

  wallpaper_path=$(pick_random || printf '')
  if [ -z "$wallpaper_path" ]; then
    echo "warning: failed to select a wallpaper; retrying in 10s" >&2
    sleep 10
    continue
  fi

  if [ "$wallpaper_path" = "$LAST_WALLPAPER" ]; then
    sleep 1
    continue
  fi

  if ! apply_wallpaper "$wallpaper_path"; then
    echo "warning: failed to set wallpaper; retrying in $INTERVAL seconds" >&2
    sleep "$INTERVAL"
    continue
  fi

  post_apply "$wallpaper_path"
  sleep "$INTERVAL"
done
