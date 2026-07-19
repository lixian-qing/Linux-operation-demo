#!/bin/bash
# 磁盘自愈: 根分区超阈值时清理日志白名单目录
# 安全: 只清日志, 绝不碰数据库数据目录
# crontab: */10 * * * * /path/disk_auto_recover.sh
set -euo pipefail

SCRIPT_NAME=disk_auto_recover
source "$(dirname "$0")/common_func.sh"
must_root

threshold=${1:-85}
# 可安全清理的日志目录
clean_dirs=(/var/log/nginx /var/log/php-fpm /var/log/audit)
log_keep=30

cur=$(disk_used /)
log_info "根分区使用率 ${cur}% (阈值 ${threshold}%)"

if (( cur < threshold )); then
    log_info "正常, 无需自愈"
    exit 0
fi

log_warn "使用率 ${cur}% 超阈值, 启动自愈清理"

for d in "${clean_dirs[@]}"; do
    [[ -d "$d" ]] || continue
    log_info "清理 $d (>${log_keep}天)"
    find "$d" -type f -mtime +"$log_keep" -delete 2>/dev/null || true
done

# 清空超期系统日志(保留文件)
find /var/log -maxdepth 1 -type f -name "*.log" -mtime +"$log_keep" -exec truncate -s 0 {} \; 2>/dev/null || true

# journald 保留 7 天
command -v journalctl >/dev/null 2>&1 && journalctl --vacuum-time=7d 2>/dev/null || true

after=$(disk_used /)
log_info "自愈完成, 清理后 ${cur}% -> ${after}%"
send_alert "磁盘自愈触发" "清理前 ${cur}% -> 清理后 ${after}%"
