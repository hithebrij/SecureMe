#!/bin/bash

# Advanced Log Analyzer & Alerting Script
# Author: Brijendra Pratap Singh
# Version: 1.0
# Description: Scans important system logs and sends alerts based on patterns.

# ========== CONFIGURATION ==========
EMAIL="you@example.com"       # Change to your alert email
LOG_DIR="/var/log"
TMP_REPORT="/tmp/log_alert_$(date +%F).log"
ALERT_LEVEL="HIGH"

# ========== PATTERNS TO WATCH ==========
declare -A patterns
patterns["SSH Failures"]="Failed password|Invalid user"
patterns["Sudo Errors"]="sudo: .*authentication failure"
patterns["Cron Errors"]="CRON.*error|CRON.*failure"
patterns["Apache Errors"]="\[error\]"
patterns["Kernel Warnings"]="kernel:.*warn"

# ========== FUNCTIONS ==========
function scan_logs() {
    echo "🕵️ Log Scan Report - $(date)" > "$TMP_REPORT"
    echo "Host: $(hostname)" >> "$TMP_REPORT"
    echo "-------------------------------" >> "$TMP_REPORT"

    for category in "${!patterns[@]}"; do
        echo -e "\n🔍 Checking: $category" >> "$TMP_REPORT"
        grep -E -i "${patterns[$category]}" $LOG_DIR/* 2>/dev/null | tail -n 10 >> "$TMP_REPORT"
    done

    echo -e "\n✅ Scan complete. Report saved to $TMP_REPORT"
}

function send_email_alert() {
    if [[ -s "$TMP_REPORT" ]]; then
        mail -s "[SecureMe] Log Alert Report - $(hostname)" "$EMAIL" < "$TMP_REPORT"
        echo "📧 Email alert sent to $EMAIL"
    else
        echo "📭 No alerts to send. Report is empty."
    fi
}

function cleanup() {
    rm -f "$TMP_REPORT"
}

# ========== MAIN EXECUTION ==========
scan_logs
send_email_alert
# Uncomment below to remove report after sending
# cleanup
