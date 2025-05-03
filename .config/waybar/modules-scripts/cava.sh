#! /bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]; do
  dict="${dict}s/$i/${bar:$i:1}/g;"
  i=$((i = i + 1))
done

# write cava config
config_file="/tmp/polybar_cava_config"
echo "
[general]
bars = 10
framerate = 60
mode = normal

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" >$config_file

# Get metadata once at start

# Start cava and parse visualizer output
cava -p "$config_file" | while read -r line; do
  # Convert raw digits to bar symbols
  visual=$(echo "$line" | sed "$dict")

  metadata=$(playerctl -a metadata --format '{ "tooltip": "{{playerName}} : {{markup_escape(artist)}} - {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}')
  # Inject visual as text, and merge with metadata
  echo "$metadata" | jq --arg text "$visual" '.text = $text' --unbuffered --compact-output
done
