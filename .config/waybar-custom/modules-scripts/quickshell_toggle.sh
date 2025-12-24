#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_qml_file>"
    exit 1
fi

TARGET="$1"
# Normalize path to absolute to ensure matching works reliably
# (Optional, but good practice if arguments vary)
# TARGET=$(realpath "$TARGET") 

# Check if the process is running.
# pgrep -f matches the full command line.
# We search for "quickshell -p <target>"
PID=$(pgrep -f "quickshell -p $TARGET")

if [ -n "$PID" ]; then
    # If running, kill it
    kill "$PID"
else
    # If not running, start it in background
    quickshell -p "$TARGET" > /dev/null 2>&1 &
fi
