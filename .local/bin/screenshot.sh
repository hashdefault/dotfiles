#!/bin/bash

# Create a temporary file for the screenshot
tmpfile=$(mktemp --suffix=.png)

# Take a snapshot of the clipboard before taking the screenshot
initial_clipboard=$(wl-paste --list-types)

# Take the screenshot
grim -g "$(slurp)" "$tmpfile" && swappy -f "$tmpfile"

sleep 1

# Check if the clipboard types have changed
current_clipboard=$(wl-paste --list-types)

# If the clipboard now contains an image and it's different from the initial state
if echo "$current_clipboard" | grep -q "image/" && [ "$initial_clipboard" != "$current_clipboard" ]; then
  notify-send -i shoot "Screenshot" "Copied to the clipboard"
fi
