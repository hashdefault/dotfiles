#!/bin/bash

eww_config="${HOME}/.config/eww"

if ! eww --config "$eww_config" ping >/dev/null 2>&1; then
    eww --config "$eww_config" daemon >/dev/null 2>&1 &
    sleep 0.25
fi

eww --config "$eww_config" open --toggle calendar_full
