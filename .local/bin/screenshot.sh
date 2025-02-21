#!/bin/bash

# Create a temporary file for the screenshot
tmpfile=$(mktemp --suffix=.png)

# Take the screenshot
grim -g "$(slurp)" "$tmpfile"

# Open in Swappy in the background & store its PID
swappy -f "$tmpfile" &
SWAPPY_PID=$!

# Cleanup function: Copy to clipboard and notify
cleanup_screenshot() {
  kill "$SWAPPY_PID" 2>/dev/null # Kill Swappy if running
  wl-copy <"$tmpfile"
  notify-send "Screenshot copied to clipboard  "
  rm -f "$tmpfile"
  exit 0
}
# Trap CTRL+C to trigger cleanup
trap cleanup SIGINT

# Wait for Swappy to close normally
wait "$SWAPPY_PID"

cleanup_screenshot
