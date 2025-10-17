#!/bin/bash
#!/bin/bash

# Check if jgmenu is running
if ! pgrep -x "jgmenu" >/dev/null; then
  # If not running, launch jgmenu
  jgmenu_run 
else
  pkill -x jgmenu
  sleep 0.2
fi
