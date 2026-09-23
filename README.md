# linux-dev-toolkit

A small Bash toolkit for practicing practical Linux administration and troubleshooting.

The repository contains three real scripts:

1. `backup.sh` — creates a dated compressed backup of a selected directory.
2. `system_report.sh` — reports disk usage, RAM, CPU information, and load.
3. `log_errors.sh` — reads a log file or a systemd service journal and finds repeated error-like messages.

## Requirements

- Linux
- Bash
- Standard command-line tools: `tar`, `date`, `df`, `du`, `free`, `awk`, `grep`, `sort`, `uniq`, `head`
- `systemd` / `journalctl` is only required when using `log_errors.sh` with a service name.

No external packages are required.

## Setup

Clone the repository and enter it:

```bash
git clone https://github.com/YOUR_USERNAME/linux-dev-toolkit.git
cd linux-dev-toolkit
```

Make the scripts executable:

```bash
chmod +x backup.sh system_report.sh log_errors.sh
```

## 1. Directory backup

Usage:

```bash
./backup.sh <source_directory> [backup_directory]
```

Example:

```bash
./backup.sh ~/projects ~/backups
```

Example output:

```text
Backup completed successfully.
Source : /home/user/projects
Archive: /home/user/backups/projects_backup_2026-09-23_22-30-15.tar.gz
Size   : 18M
```

The timestamp makes it possible to keep multiple backups instead of overwriting the previous one.

### Permissions note

The script can only read files that the current user is allowed to read. If the source contains protected files, you may see a permission error from `tar`. Avoid using `sudo` unless you actually need elevated privileges.

## 2. Linux system report

Usage:

```bash
./system_report.sh
```

Save the report to a file:

```bash
./system_report.sh system-report.txt
```

Example output:

```text
Linux System Report
===================
Generated : 2026-09-23 22:31:00
Hostname  : dev-machine
Kernel    : 6.x.x

CPU
---
Model     : Intel(R) Core(TM) i5 CPU
CPU cores : 4
Load 1m   : 0.42

Memory
------
Total     : 3820 MiB
Used      : 2140 MiB
Available : 1680 MiB

Disk (/)
--------
Total     : 110G
Used      : 78G
Available : 27G
Used %    : 75%
```

The script reads:

- `df` for filesystem usage.
- `free` for RAM.
- `/proc/cpuinfo` for CPU information.
- `/proc/loadavg` for the one-minute load average.

## 3. Log error analysis

Analyze a log file:

```bash
./log_errors.sh /var/log/syslog
```

Ask for the top 5 repeated errors:

```bash
./log_errors.sh /var/log/syslog 5
```

Analyze a systemd service:

```bash
./log_errors.sh nginx
```

Example output:

```text
Log Error Report
================
Source: /var/log/syslog

Top 5 repeated error lines:
--------------------------------
     12 Connection refused by upstream
      8 Failed to open configuration file
      5 Permission denied
      3 Database connection failed
      2 Timeout while waiting for response

Total matching error lines: 30
```

The script looks for common error-related words such as:

```text
error
failed
failure
fatal
critical
exception
```

It then sorts matching lines, counts duplicates, and shows the most frequent ones.

## What I learned

### Processes

Linux programs run as processes. The system exposes useful process and system information through tools and virtual files such as `/proc`.

The toolkit uses `/proc/loadavg` and `/proc/cpuinfo` to collect system information.

Useful commands to continue practicing:

```bash
ps aux
top
htop
pgrep
kill
```

### Permissions

Linux controls access using users, groups, and permission bits.

Useful commands:

```bash
ls -l
chmod
chown
id
```

For example:

```bash
chmod +x backup.sh
```

adds executable permission for the appropriate permission classes according to the file's existing mode.

### Logs

Logs are one of the first places to investigate when a service fails.

Traditional log files can be inspected with:

```bash
less /var/log/syslog
grep -i error /var/log/syslog
```

On systemd-based Linux systems, service logs can be queried with:

```bash
journalctl -u nginx
journalctl -u nginx --since "1 hour ago"
```

The `log_errors.sh` script combines these ideas with `grep`, `sort`, `uniq`, and `head` to identify repeated error messages.

## Suggested practice

Try extending the toolkit with:

- A process-monitoring script that lists the top CPU-consuming processes.
- A disk cleanup report that finds the largest directories.
- A service health-check script using `systemctl is-active`.
- Log filtering by date or time range.
- A cron job that runs the backup automatically.

## Project goal

This is intentionally a small Bash project rather than a collection of toy commands. The goal is to practice Linux concepts by turning common administration tasks into reusable scripts.
