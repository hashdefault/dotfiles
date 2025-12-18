#!/usr/bin/env bash

# toggle.sh: Toggles a Quickshell instance.
# Usage: ./toggle.sh <qml_file> <unique_id>
# Example: ./toggle.sh PowerMenu/PowerMenuWindow.qml PowerMenu

QML_PATH="$1"
ID="$2"

if [ -z "$QML_PATH" ] || [ -z "$ID" ]; then
    echo "Usage: $0 <qml_path> <unique_id>"
    exit 1
fi

PID_FILE="/tmp/quickshell_${ID}.pid"

# Check if PID file exists
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    # Check if process is still running
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Killing existing process $PID"
        kill "$PID"
        rm "$PID_FILE"
        exit 0
    else
        # Process is dead but PID file remains
        echo "Cleaning up stale PID file"
        rm "$PID_FILE"
    fi
fi

# Get the directory of this script to resolve paths if needed,
# but usually quickshell works relative to CWD or absolute.
# We assume this script is called from the config root or paths are absolute.

echo "Starting Quickshell: $QML_PATH"
# Run quickshell detached
nohup quickshell -p "$QML_PATH" > /dev/null 2>&1 &
NEW_PID=$!
echo $NEW_PID > "$PID_FILE"
echo "Started with PID $NEW_PID"
