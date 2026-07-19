#!/bin/bash
# 核心服务守护, 异常自动重启并告警
# crontab: */2 * * * * /path/service_repair.sh
set -euo pipefail

SCRIPT_NAME=service_repair
source "$(dirname "$0")/common_func.sh"
must_root

services=(nginx php-fpm mysqld)
repaired=0

for s in "${services[@]}"; do
    systemctl list-unit-files "$s.service" >/dev/null 2>&1 || continue
    if systemctl is-active --quiet "$s"; then
        log_info "$s 正常"
        continue
    fi
    log_warn "$s 异常, 尝试重启"
    if systemctl restart "$s" 2>>"$LOG_FILE"; then
        sleep 1
        if systemctl is-active --quiet "$s"; then
            log_info "$s 重启成功"
            send_alert "服务自愈" "$s 异常已自动恢复"
        else
            log_error "$s 重启后仍异常, 需人工介入"
            send_alert "服务自愈失败" "$s 重启后仍异常, 请立即处理"
        fi
        repaired=1
    else
        log_error "$s 重启失败"
    fi
done

if (( repaired == 0 )); then
    log_info "所有核心服务正常"
fi
