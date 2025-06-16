#!/usr/bin/env bash

case $(dunstctl is-paused) in
true)
  dunstctl set-paused false &
  dunstify -i notification-active -a "System" "Do Not Disturb" "Turned Off" &
  ;;
false)
  dunstify -i notification-inactive -a "System" "Do Not Disturb" "Active" &
  (sleep 3 && dunstctl close && dunstctl set-paused true)
  ;;
esac
