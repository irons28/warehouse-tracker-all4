#!/usr/bin/env bash
set -euo pipefail

# One-time setup for a stable Cloudflare domain tunnel.
# Requirements:
# 1) You own a domain in Cloudflare DNS
# 2) cloudflared installed and logged in
# 3) local app runs on http://127.0.0.1:3000

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared not found. Install first: brew install cloudflared"
  exit 1
fi

read -r -p "Tunnel name (e.g. wt-all4): " TUNNEL_NAME
read -r -p "Fixed hostname (e.g. tracker.all4logistics.com): " HOSTNAME

if [ -z "${TUNNEL_NAME}" ] || [ -z "${HOSTNAME}" ]; then
  echo "Tunnel name and hostname are required."
  exit 1
fi

echo "\n[1/5] Cloudflare login (browser will open if needed)"
cloudflared tunnel login

echo "\n[2/5] Create tunnel"
cloudflared tunnel create "${TUNNEL_NAME}"

TUNNEL_ID="$(cloudflared tunnel list | awk -v n="${TUNNEL_NAME}" '$0 ~ n {print $1; exit}')"
if [ -z "${TUNNEL_ID}" ]; then
  echo "Unable to find tunnel id for ${TUNNEL_NAME}"
  exit 1
fi

CREDS_FILE="${HOME}/.cloudflared/${TUNNEL_ID}.json"
CONFIG_FILE="${HOME}/.cloudflared/config.yml"
mkdir -p "${HOME}/.cloudflared"

echo "\n[3/5] Write ${CONFIG_FILE}"
cat > "${CONFIG_FILE}" <<CFG
tunnel: ${TUNNEL_ID}
credentials-file: ${CREDS_FILE}
ingress:
  - hostname: ${HOSTNAME}
    service: http://127.0.0.1:3000
  - service: http_status:404
CFG

echo "\n[4/5] Route DNS"
cloudflared tunnel route dns "${TUNNEL_NAME}" "${HOSTNAME}"

echo "\n[5/5] Test tunnel"
cloudflared tunnel run "${TUNNEL_NAME}" &
PID=$!
sleep 4
kill "$PID" >/dev/null 2>&1 || true

echo "\nDone. Fixed domain configured: https://${HOSTNAME}"
echo "Start it any time with: npm run tunnel:fixed"
