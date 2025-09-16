#!/usr/bin/env bash

# Minimal weather output for xmobar: icon + temperature (like Waybar)
# - Uses wttr.in with a concise format.
# - Respects an optional first arg for location (e.g., "London" or "48.85,2.35").
# - Falls back to a simple cloud icon on failure.

set -euo pipefail

LOCATION="maringa,pr,brazil"

if [[ -n "$LOCATION" ]]; then
  URL="https://wttr.in/${LOCATION}?format=%c%20%t&m"
else
  URL="https://wttr.in?format=%c%20%t&m"
fi

output="$(curl -fsS --connect-timeout 2 --max-time 4 "$URL" || true)"

if [[ -z "$output" ]] || [[ "$output" == *"Unknown location"* ]]; then
  # Fallback: Font Awesome cloud + placeholder
  echo $'\uf0c2 --'
else
  echo "$output"
fi

