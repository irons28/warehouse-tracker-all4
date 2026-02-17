#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-3000}"

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared is not installed."
  echo "Install on macOS: brew install cloudflared"
  exit 1
fi

echo "Starting Cloudflare quick tunnel to http://localhost:${PORT}"
echo "Keep this terminal open."
cloudflared tunnel --url "http://localhost:${PORT}" --no-autoupdate
