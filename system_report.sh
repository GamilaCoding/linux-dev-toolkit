#!/usr/bin/env bash
set -euo pipefail

REPORT_FILE="${1:-}"

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
hostname="$(hostname)"
kernel="$(uname -r)"

# Disk usage for the root filesystem.
disk_line="$(df -h / | awk 'NR==2 {print $2, $3, $4, $5}')"
read -r disk_total disk_used disk_available disk_percent <<< "$disk_line"

# Memory information in MiB.
read -r mem_total mem_used mem_available <<< "$(free -m | awk '/^Mem:/ {print $2, $3, $7}')"

# 1-minute load average.
load_1m="$(awk '{print $1}' /proc/loadavg)"

# CPU count and current CPU model.
cpu_count="$(nproc)"
cpu_model="$(awk -F: '/model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' /proc/cpuinfo)"

{
  echo "Linux System Report"
  echo "==================="
  echo "Generated : $timestamp"
  echo "Hostname  : $hostname"
  echo "Kernel    : $kernel"
  echo
  echo "CPU"
  echo "---"
  echo "Model     : ${cpu_model:-Unknown}"
  echo "CPU cores : $cpu_count"
  echo "Load 1m   : $load_1m"
  echo
  echo "Memory"
  echo "------"
  echo "Total     : ${mem_total} MiB"
  echo "Used      : ${mem_used} MiB"
  echo "Available : ${mem_available} MiB"
  echo
  echo "Disk (/)"
  echo "--------"
  echo "Total     : $disk_total"
  echo "Used      : $disk_used"
  echo "Available : $disk_available"
  echo "Used %    : $disk_percent"
} | tee "${REPORT_FILE:-/dev/stdout}"
