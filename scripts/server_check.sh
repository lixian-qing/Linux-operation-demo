#!/bin/bash
# 服务器巡检, 采集系统/负载/内存/磁盘/端口/登录用户写日志
# 磁盘超阈值告警
# crontab: 0 */4 * * * /path/server_check.sh
set -euo pipefail

SCRIPT_NAME=server_check
source "$(dirname "$0")/common_func.sh"
must_root

DISK_THRESHOLD=${1:-85}

log_info "==================== 巡检报告 $(date) ===================="

section() { log_info ""; log_info "【$1】"; }

section "1.系统基础信息"
{
    echo "主机名: $(hostname)"
    echo "内核:   $(uname -r)"
    echo "系统:   $(cat /etc/redhat-release 2>/dev/null || awk -F= '/PRETTY_NAME/{gsub(/"/,"",$2);print $2}' /etc/os-release)"
    echo "时间:   $(date '+%F %T %Z')"
} >> "$LOG_FILE"

section "2.负载"
uptime >> "$LOG_FILE"

section "3.内存"
free -h >> "$LOG_FILE"

section "4.磁盘"
df -h | grep -v tmpfs >> "$LOG_FILE"

section "5.监听端口"
ss -ltnp >> "$LOG_FILE"

section "6.登录用户"
who >> "$LOG_FILE"

log_info ""
hit=0
while read -r used mnt; do
    [[ -z "$used" ]] && continue
    if (( used >= DISK_THRESHOLD )); then
        log_warn "磁盘告警: $mnt 使用率 ${used}% (阈值 ${DISK_THRESHOLD}%)"
        hit=1
    fi
done < <(df -P | awk 'NR>1 && $1!~/tmpfs/{gsub(/%/,"",$5); print $5,$6}')

(( hit )) && send_alert "磁盘空间告警" "详见 $LOG_FILE"

log_info "============================================================"
log_info "巡检完成 -> $LOG_FILE"
