#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/backups"
LATEST="$(ls -1t "${BACKUP_DIR}"/warehouse-backup-*.db.gz 2>/dev/null | head -n 1 || true)"

if [ -z "$LATEST" ] || [ ! -f "$LATEST" ]; then
  echo "No .db.gz backup found. Run db-backup-rotate.sh first."
  exit 1
fi

if [ -n "${BACKUP_RCLONE_REMOTE:-}" ]; then
  if ! command -v rclone >/dev/null 2>&1; then
    echo "rclone not installed (required for BACKUP_RCLONE_REMOTE upload)."
    exit 1
  fi
  rclone copy "$LATEST" "$BACKUP_RCLONE_REMOTE"
  echo "Uploaded via rclone: $LATEST -> $BACKUP_RCLONE_REMOTE"
  exit 0
fi

if [ -n "${BACKUP_S3_URI:-}" ]; then
  if ! command -v aws >/dev/null 2>&1; then
    echo "aws cli not installed (required for BACKUP_S3_URI upload)."
    exit 1
  fi
  aws s3 cp "$LATEST" "$BACKUP_S3_URI"
  echo "Uploaded to S3: $LATEST -> $BACKUP_S3_URI"
  exit 0
fi

echo "No upload target set. Configure BACKUP_RCLONE_REMOTE or BACKUP_S3_URI in .env"
exit 1
