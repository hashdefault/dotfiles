#!/usr/bin/env bash
set -euo pipefail

# Present greenclip entries in rofi (same theme as before) and copy the chosen one to the clipboard.
selection="$(greenclip print | rofi -dmenu -p ' ' )"

if [[ -z "${selection}" ]]; then
  exit 0
fi

# Print the selected line so it can be captured by callers if needed.
printf '%s\n' "${selection}"

# Copy selection to clipboard.
printf '%s' "${selection}" | xclip -selection clipboard
