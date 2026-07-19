#!/bin/bash
# 日志清理
# 1) 项目 logs/ 下超期日志直接删
# 2) /var/log/*.log 超期清空内容(保留文件, 不破坏句柄)
# 注意: 不碰 /var/lib/* 数据目录
# crontab: 0 3 * * * /path/log_clear.sh
set -euo pipefail

SCRIPT_NAME=log_clear
source "$(dirname "$0")/common_func.sh"

keep=${LOG_KEEP_DAYS:-7}

log_info "清理项目日志 $LOG_DIR (>${keep}天)"
find "$LOG_DIR" -type f -name "*.log" -mtime +"$keep" -delete 2>/dev/null || true

log_info "清理系统日志 /var/log/*.log (清空, >${keep}天)"
find /var/log -maxdepth 1 -type f -name "*.log" -mtime +"$keep" -print -exec truncate -s 0 {} \; 2>/dev/null || true

log_info "日志清理完成"
