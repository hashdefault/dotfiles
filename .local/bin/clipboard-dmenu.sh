#!/usr/bin/env bash
set -euo pipefail

# Present greenclip entries in dmenu and copy the chosen one to the clipboard.
selection="$(greenclip print | dmenu -i -l 12 -p ' ' \
    -fn 'JetBrainsMono Nerd Font-10' \
    -nb '#121222' -nf '#dcdcdc' \
    -sb '#00ff99' -sf '#121222')"

if [[ -z "${selection}" ]]; then
  exit 0
fi

# Print the selected line so it can be captured by callers if needed.
printf '%s\n' "${selection}"

# Copy selection to clipboard (support both X11 and Wayland)
if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  printf '%s' "${selection}" | wl-copy
  printf '%s' "${selection}" | wl-copy --primary
else
  printf '%s' "${selection}" | xclip -selection clipboard
  printf '%s' "${selection}" | xclip -selection primary
fi
