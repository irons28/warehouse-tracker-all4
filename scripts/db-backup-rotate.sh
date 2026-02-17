#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEEP_DAYS="${BACKUP_RETENTION_DAYS:-30}"

if ! [[ "$KEEP_DAYS" =~ ^[0-9]+$ ]]; then
  echo "BACKUP_RETENTION_DAYS must be an integer"
  exit 1
fi

BACKUP_OUTPUT="$(bash "${ROOT_DIR}/scripts/db-backup.sh")"
echo "$BACKUP_OUTPUT"

LATEST_PATH="$(echo "$BACKUP_OUTPUT" | sed -n 's/^Backup created: //p' | tail -n 1)"
if [ -n "$LATEST_PATH" ] && [ -f "$LATEST_PATH" ]; then
  gzip -f "$LATEST_PATH"
  echo "Compressed: ${LATEST_PATH}.gz"
fi

find "${ROOT_DIR}/backups" -type f -name 'warehouse-backup-*.db.gz' -mtime +"$KEEP_DAYS" -print -delete || true

echo "Backup rotation complete (retention: ${KEEP_DAYS} days)"
