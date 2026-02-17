#!/usr/bin/env bash
set -euo pipefail

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared not found. Install first: brew install cloudflared"
  exit 1
fi

CONFIG_FILE="${HOME}/.cloudflared/config.yml"
if [ ! -f "${CONFIG_FILE}" ]; then
  echo "Missing ${CONFIG_FILE}. Run setup first:"
  echo "  bash ./scripts/setup-fixed-domain-cloudflare.sh"
  exit 1
fi

echo "Starting Cloudflare fixed-domain tunnel using ${CONFIG_FILE}"
cloudflared tunnel run
