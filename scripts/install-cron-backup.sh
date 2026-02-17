#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CRON_EXPR="${1:-0 2 * * *}"
CRON_CMD="cd ${ROOT_DIR} && bash ./scripts/nightly-backup.sh >> ./logs/backup.log 2>&1"

TMP_CRON="$(mktemp)"
crontab -l 2>/dev/null | grep -v "nightly-backup.sh" > "$TMP_CRON" || true
echo "$CRON_EXPR $CRON_CMD" >> "$TMP_CRON"
crontab "$TMP_CRON"
rm -f "$TMP_CRON"

echo "Installed cron job: $CRON_EXPR"
echo "Command: $CRON_CMD"
