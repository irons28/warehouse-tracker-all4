#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"
SERVER_PID_FILE="$ROOT_DIR/.wt-server.pid"
TUNNEL_PID_FILE="$ROOT_DIR/.wt-tunnel.pid"

mkdir -p "$LOG_DIR"
cd "$ROOT_DIR"

if [ ! -d "$ROOT_DIR/node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

if [ ! -f "$ROOT_DIR/server.js" ]; then
  echo "server.js not found in: $ROOT_DIR"
  exit 1
fi

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared is not installed."
  echo "Install it first (macOS): brew install cloudflared"
  exit 1
fi

start_process_if_needed() {
  local pid_file="$1"
  local cmd="$2"
  local log_file="$3"

  if [ -f "$pid_file" ]; then
    local existing_pid
    existing_pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
      echo "Already running (PID $existing_pid): $cmd"
      return 0
    fi
  fi

  echo "Starting: $cmd"
  nohup bash -lc "$cmd" >"$log_file" 2>&1 &
  local new_pid=$!
  echo "$new_pid" > "$pid_file"
  sleep 1

  if ! kill -0 "$new_pid" 2>/dev/null; then
    echo "Failed to start: $cmd"
    echo "Check log: $log_file"
    exit 1
  fi
}

start_process_if_needed "$SERVER_PID_FILE" "npm start" "$LOG_DIR/server.log"

TUNNEL_CMD="npm run tunnel:cf"
if [ -f "${HOME}/.cloudflared/config.yml" ]; then
  TUNNEL_CMD="npm run tunnel:fixed"
fi
start_process_if_needed "$TUNNEL_PID_FILE" "$TUNNEL_CMD" "$LOG_DIR/tunnel.log"

echo ""
echo "Warehouse Tracker started."
echo "Local URL: https://localhost:3443"
echo "Server log: $LOG_DIR/server.log"
echo "Tunnel log: $LOG_DIR/tunnel.log"
echo ""

# Try to print fixed hostname from cloudflared config, then fallback to quick tunnel URL.
fixed_host="$(grep -E '^[[:space:]]*-?[[:space:]]*hostname:' "${HOME}/.cloudflared/config.yml" 2>/dev/null | head -n 1 | sed -E 's/.*hostname:[[:space:]]*//')"
if [ -n "$fixed_host" ]; then
  echo "Mobile URL (fixed): https://${fixed_host}"
else
  tunnel_url="$(grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' "$LOG_DIR/tunnel.log" | tail -n 1 || true)"
  if [ -n "$tunnel_url" ]; then
    echo "Mobile URL: $tunnel_url"
  else
    echo "Waiting for tunnel URL..."
    echo "Run this to check: grep -Eo 'https://[a-zA-Z0-9.-]+\\.trycloudflare\\.com' logs/tunnel.log | tail -n 1"
  fi
fi
