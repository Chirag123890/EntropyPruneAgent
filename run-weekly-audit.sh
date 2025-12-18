#!/bin/bash
timestamp=$(date +"%Y-%m-%d_%H-%M")
logfile="/root/audit-logs/audit_$timestamp.txt"
pwsh -File /root/EntropyPruneAgent/audit-prune.ps1 > "$logfile"
