#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DB_PATH="${ROOT_DIR}/warehouse.db"
BACKUP_DIR="${ROOT_DIR}/backups"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_PATH="${BACKUP_DIR}/warehouse-backup-${STAMP}.db"

mkdir -p "${BACKUP_DIR}"

if [ ! -f "${DB_PATH}" ]; then
  echo "Database not found at ${DB_PATH}"
  exit 1
fi

sqlite3 "${DB_PATH}" "PRAGMA wal_checkpoint(FULL);" >/dev/null 2>&1 || true
cp "${DB_PATH}" "${OUT_PATH}"

echo "Backup created: ${OUT_PATH}"
