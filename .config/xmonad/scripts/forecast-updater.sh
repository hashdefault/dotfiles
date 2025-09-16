#!/usr/bin/env bash

set -euo pipefail

SCRIPT="$HOME/.config/eww/scripts/getforecast"
CACHE_DIR="$HOME/.cache/eww"
LOCK_FILE="$CACHE_DIR/forecast.lock"

mkdir -p "$CACHE_DIR"

# Ensure the upstream script exists
if [[ ! -x "$SCRIPT" ]]; then
  echo "getforecast script not found or not executable: $SCRIPT" >&2
  exit 0
fi

# Single-instance guard via flock
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  # Another instance is already running
  exit 0
fi

while true; do
  # Run the forecast updater; ignore failures to keep the loop alive
  "$SCRIPT" >/dev/null 2>&1 || true
  # Sleep for 2 hours
  sleep 7200
done

