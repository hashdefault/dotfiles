#!/bin/bash

appname=$(echo "$1" | sed '/^$/d')
summary=$(echo "$2" | sed '/^$/d' | xargs)
body=$(echo "$3" | sed '/^$/d' | xargs)
icon=$(echo "$4" | sed '/^$/d')
urgency=$(echo "$5" | sed '/^$/d')
timestamp=$(date +"%I:%M %p")

if [[ "$appname" == "Spotify" ]]; then
  random_name=$(mktemp --suffix ".png")
  artlink=$(playerctl metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')
  curl -s "$artlink" -o "$random_name"
  icon=$random_name
elif [[ "$appname" == "VLC media player" ]]; then
  icon="vlc"
elif [[ "$appname" == "Calendar" ]] || [[ "$appname" == "Volume" ]] || [[ "$appname" == "Brightness" ]]; then
  exit 0
fi

notification_item="$timestamp;$urgency;$icon;$body;$summary;$appname"

tmp=$(mktemp)
echo "$notification_item" >"$tmp"
cat /tmp/dunstlog >>"$tmp"
mv "$tmp" "/tmp/dunstlog"
