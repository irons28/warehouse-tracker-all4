#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_PID_FILE="$ROOT_DIR/.wt-server.pid"
TUNNEL_PID_FILE="$ROOT_DIR/.wt-tunnel.pid"

stop_from_pid_file() {
  local pid_file="$1"
  local name="$2"

  if [ ! -f "$pid_file" ]; then
    echo "$name: PID file not found"
    return 0
  fi

  local pid
  pid="$(cat "$pid_file" 2>/dev/null || true)"
  if [ -z "$pid" ]; then
    echo "$name: PID file empty"
    rm -f "$pid_file"
    return 0
  fi

  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
    echo "$name stopped (PID $pid)"
  else
    echo "$name was not running"
  fi

  rm -f "$pid_file"
}

stop_from_pid_file "$SERVER_PID_FILE" "Server"
stop_from_pid_file "$TUNNEL_PID_FILE" "Tunnel"

echo "Warehouse Tracker stopped."
