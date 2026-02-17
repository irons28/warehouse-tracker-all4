#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "${ROOT_DIR}/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "${ROOT_DIR}/.env"
  set +a
fi

bash "${ROOT_DIR}/scripts/db-backup-rotate.sh"

# Upload is optional; will fail only if target is configured incorrectly.
if [ -n "${BACKUP_RCLONE_REMOTE:-}" ] || [ -n "${BACKUP_S3_URI:-}" ]; then
  bash "${ROOT_DIR}/scripts/db-backup-upload.sh"
else
  echo "No remote backup target configured; local backup only."
fi
