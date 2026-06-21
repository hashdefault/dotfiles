#!/bin/bash

window_name="$1"
eww_config="${HOME}/.config/eww"

if [ -z "$window_name" ]; then
    exit 2
fi

if ! eww --config "$eww_config" ping >/dev/null 2>&1; then
    eww --config "$eww_config" daemon >/dev/null 2>&1 &
    sleep 0.4
fi

eww --config "$eww_config" open --toggle "$window_name"
