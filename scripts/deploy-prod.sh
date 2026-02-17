#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p logs backups

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

echo "1) Installing production dependencies"
npm ci --omit=dev

echo "2) Running release preflight"
npm run preflight:release

echo "3) Starting/reloading process"
if command -v pm2 >/dev/null 2>&1; then
  pm2 startOrReload ecosystem.config.js --update-env
  pm2 save
  echo "PM2 process started/reloaded."
else
  echo "PM2 not found. Starting foreground process instead."
  echo "Install PM2 for managed deployment: npm i -g pm2"
  npm run start:prod
fi
