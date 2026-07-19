#!/bin/bash
# 安全风险扫描, 发现当前存在的隐患
# 需 root(读 /etc/shadow)
set -euo pipefail

SCRIPT_NAME=security_scan
source "$(dirname "$0")/common_func.sh"
must_root

log_info "===== 安全风险扫描 $(date) ====="

log_info "--- 弱口令/空口令 ---"
awk -F: '($2==""||$2=="!"||$2=="*"){print "空/锁: "$1}
         ($2!~/^[!*]/ && length($2)<6){print "过短: "$1}' /etc/shadow >> "$LOG_FILE" 2>/dev/null || true

log_info "--- 高危端口监听 ---"
ss -tlnp 2>/dev/null | awk '{print $4}' | grep -E ':(3306|6379|23|3389|445|11211)$' >> "$LOG_FILE" || log_info "未发现高危端口"

log_info "--- 异常 SUID 文件 ---"
find / -perm -4000 -type f 2>/dev/null | grep -vE '^/(usr/(bin|sbin)|bin|sbin)/' >> "$LOG_FILE" || log_info "无异常 SUID"

log_info "--- cron 可写检测 ---"
find /etc/cron* -perm /o+w -type f 2>/dev/null >> "$LOG_FILE" || log_info "cron 权限正常"

log_info "--- SELinux 状态 ---"
if command -v getenforce >/dev/null 2>&1; then
    log_info "SELinux: $(getenforce)"
else
    log_info "SELinux 未安装"
fi

log_info "===== 扫描完成 -> $LOG_FILE ====="
