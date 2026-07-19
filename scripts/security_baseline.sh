#!/bin/bash
# 安全基线合规检查, 逐项输出 PASS/FAIL
# 需 root
set -euo pipefail

SCRIPT_NAME=security_baseline
source "$(dirname "$0")/common_func.sh"
must_root

pass=0; fail=0

# check <描述> <检测命令...>  返回0即合规
check() {
    local desc=$1; shift
    if "$@" >/dev/null 2>&1; then
        log_info "[PASS] $desc"; pass=$((pass+1))
    else
        log_warn "[FAIL] $desc"; fail=$((fail+1))
    fi
}

log_info "===== 安全基线检查 $(date) ====="

check "SELinux Enforcing"            bash -c '[[ "$(getenforce 2>/dev/null)" == Enforcing ]]'
check "SSH 禁止 root 密码登录"        grep -qE '^PermitRootLogin\s+(no|prohibit-password)' /etc/ssh/sshd_config
check "SSH 禁用密码认证(仅密钥)"      grep -qE '^PasswordAuthentication\s+no' /etc/ssh/sshd_config
check "密码最长使用<=90天"            bash -c 'grep -qE "^PASS_MAX_DAYS\s+([0-8][0-9]|90)$" /etc/login.defs'
check "密码最小长度>=8"               bash -c 'grep -qE "^PASS_MIN_LEN\s+([89]|[1-9][0-9]+)$" /etc/login.defs'
check "history<=100条"               bash -c 'grep -qE "^HISTSIZE\s+([0-9]|[1-9][0-9]|100)$" /etc/profile'
check "无空口令账号"                  bash -c '! awk -F: "(\$2==\"\"){exit 1}" /etc/shadow'

for s in nginx php-fpm mysqld; do
    systemctl list-unit-files "$s.service" >/dev/null 2>&1 && check "$s 开机自启" systemctl is-enabled "$s"
done

log_info "===== 基线: 通过 $pass / 不通过 $fail ====="

if (( fail > 0 )); then
    send_alert "安全基线不合规" "$fail 项不通过, 详见 $LOG_FILE"
fi
