#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="${2:-$HOME/backups}"

if [[ -z "$SOURCE_DIR" ]]; then
  echo "Usage: $0 <source_directory> [backup_directory]"
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: source directory does not exist: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
SOURCE_NAME="$(basename "$(realpath "$SOURCE_DIR")")"
ARCHIVE="$BACKUP_DIR/${SOURCE_NAME}_backup_${TIMESTAMP}.tar.gz"

tar -czf "$ARCHIVE" -C "$(dirname "$(realpath "$SOURCE_DIR")")" "$SOURCE_NAME"

echo "Backup completed successfully."
echo "Source : $(realpath "$SOURCE_DIR")"
echo "Archive: $ARCHIVE"
echo "Size   : $(du -h "$ARCHIVE" | awk '{print $1}')"
