#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#run "megasync"
run "xscreensaver -no-splash"
#run "insync start"
run "picom"
run "nitrogen --restore"
#run "/usr/bin/redshift"
run "mpd"
run "nm-applet"
