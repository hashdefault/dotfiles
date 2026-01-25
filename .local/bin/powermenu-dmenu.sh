#!/bin/sh

# 1. Define the options
options="Shutdown\nReboot\nSuspend\nLogout\nLock"

# 2. Show the menu with dmenu
selected=$(echo -e "$options" | dmenu -i -fn "JetBrainsMono Nerd Font:size=10" -l 5 -p "Power:" \
  -nb '#121222' -nf '#dcdcdc' -sb '#00ff99' -sf '#121222')

# 3. Execute the choice
case "$selected" in
Shutdown)
  systemctl poweroff
  ;;
Reboot)
  systemctl reboot
  ;;
Suspend)
  systemctl suspend
  ;;
Logout)
  pkill qtile
  ;;
Lock)
  exec ~/.local/bin/swaylock-screen
  ;;
esac
