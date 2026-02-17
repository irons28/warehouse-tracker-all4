#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "1) Syntax checks"
node --check "${ROOT_DIR}/server.js"
node --check "${ROOT_DIR}/public/app.js"

echo "2) Config file checks"
if [ -f "${ROOT_DIR}/.env" ]; then
  echo ".env found."
else
  echo ".env not found (ok for local defaults, recommended for production)."
fi

if [ -f "${ROOT_DIR}/server-settings.json" ]; then
  echo "server-settings.json found."
else
  echo "ERROR: server-settings.json missing."
  exit 1
fi

if [ -x "${ROOT_DIR}/scripts/phase1-regression.sh" ]; then
  echo "3) Regression script syntax"
  bash -n "${ROOT_DIR}/scripts/phase1-regression.sh"
fi

echo "4) Health endpoint checks (if server is running)"
if curl -fsS "http://localhost:3000/api/health" >/dev/null 2>&1; then
  echo "Health endpoint reachable on HTTP."
else
  echo "Health endpoint not reachable on HTTP (server may be stopped)."
fi

if curl -kfsS "https://localhost:3443/api/health" >/dev/null 2>&1; then
  echo "Health endpoint reachable on HTTPS."
else
  echo "Health endpoint not reachable on HTTPS (SSL may be disabled)."
fi

echo "Preflight complete."
