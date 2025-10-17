#!/bin/bash

# Create a temporary file for the screenshot
tmpfile=$(mktemp --suffix=.png)

# Take the screenshot
screenshot=$(grim -g "$(slurp)" "$tmpfile" && swappy -f "$tmpfile")

# If the clipboard now contains an image and it's different from the initial state
if echo "$screenshot"; then
  dunstify -a "Screenshot" -i "$tmpfile" -p "Screenshot" "Copied to the clipboard"
fi
