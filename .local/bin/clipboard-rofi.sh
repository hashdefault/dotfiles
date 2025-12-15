#!/usr/bin/env bash
set -euo pipefail

# Present greenclip entries in rofi (same theme as before) and copy the chosen one to the clipboard.
theme="${HOME}/.config/rofi/launcher/style.rasi"
selection="$(greenclip print | rofi -dmenu -p ' ' -theme "${theme}")"

if [[ -z "${selection}" ]]; then
  exit 0
fi

# Print the selected line so it can be captured by callers if needed.
printf '%s\n' "${selection}"

# Copy selection to both clipboards.
printf '%s' "${selection}" | wl-copy
printf '%s' "${selection}" | wl-copy --primary
