#!/usr/bin/env bash
# REA (AETHER Insights) MCP Server Launcher
# Auto-detects location - works from USB or laptop

# Get the directory where this script is located
REA_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REA_DIR"

# PID file (local to REA directory)
PID_FILE="$REA_DIR/rea.pid"

# Check if already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "REA already running (PID: $PID)"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Start REA server
nohup node "$REA_DIR/server.js" > "$REA_DIR/rea.log" 2>&1 &
echo $! > "$PID_FILE"

echo "REA started (PID: $(cat "$PID_FILE"))"
