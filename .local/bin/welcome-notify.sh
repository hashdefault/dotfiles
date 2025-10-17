#!/usr/bin/env bash
set -euo pipefail

# Send a one-time welcome notification via dunstify on login.
# - Uses a small stock icon (can be overridden by arg/path)
# - Skips if not in a graphical session or if dunstify is missing
# - Ensures it only fires once per user session

# Only run in a graphical session
if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  exit 0
fi

# Require dunstify
if ! command -v dunstify >/dev/null 2>&1; then
  exit 0
fi

# Ensure only once per session
lock_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}"
lock_file="$lock_dir/.welcome-notify.lock"
mkdir -p "$lock_dir"
if [[ -f "$lock_file" ]]; then
  exit 0
fi

user_name="${USER:-$(id -un)}"

# Allow overriding the icon via first arg (icon name or full path)
icon="${1:-dialog-information}"

summary="👋 Welcome, $user_name"
body="$(date +'%A, %B %d, %Y %H:%M')"

# Send notification (low urgency, stack to avoid duplicates)
dunstify \
  -a "Login" \
  -u low \
  -i "$icon" \
  -h string:x-dunst-stack-tag:welcome-login \
  "$summary" "$body" || true

# Mark as shown for this session
: > "$lock_file"

