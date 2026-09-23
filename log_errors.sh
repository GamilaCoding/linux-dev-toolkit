#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-}"
TOP_N="${2:-10}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 <log_file_or_service> [number_of_errors]"
  echo
  echo "Examples:"
  echo "  $0 /var/log/syslog"
  echo "  $0 nginx 10"
  exit 1
fi

if ! [[ "$TOP_N" =~ ^[0-9]+$ ]] || [[ "$TOP_N" -lt 1 ]]; then
  echo "Error: number_of_errors must be a positive integer."
  exit 1
fi

TMP_LOG="$(mktemp)"
trap 'rm -f "$TMP_LOG"' EXIT

if [[ -f "$INPUT" ]]; then
  cat "$INPUT" > "$TMP_LOG"
  SOURCE_DESCRIPTION="$INPUT"
elif command -v journalctl >/dev/null 2>&1 && systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}' | grep -qx "$INPUT"; then
  journalctl -u "$INPUT" --no-pager > "$TMP_LOG"
  SOURCE_DESCRIPTION="systemd service: $INPUT"
else
  echo "Error: '$INPUT' is not a readable log file or known systemd service."
  exit 1
fi

echo "Log Error Report"
echo "================"
echo "Source: $SOURCE_DESCRIPTION"
echo

echo "Top $TOP_N repeated error lines:"
echo "--------------------------------"
grep -iE 'error|err|failed|failure|fatal|critical|exception' "$TMP_LOG" \
  | sed 's/^[[:space:]]*//' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n "$TOP_N" \
  || true

echo
echo "Total matching error lines: $(grep -icE 'error|err|failed|failure|fatal|critical|exception' "$TMP_LOG" || true)"
