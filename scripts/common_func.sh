#!/bin/bash
# 公共函数库, 各脚本 source 后可用
# 用法: SCRIPT_NAME=xxx; source "$(dirname "$0")/common_func.sh"

[[ -n "${_COMMON_FUNC_LOADED:-}" ]] && return 0
_COMMON_FUNC_LOADED=1

# 项目根 (本文件在 scripts/ 下)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
BACKUP_DIR="$PROJECT_ROOT/data/mysql_back"

# 日志文件, 调用方可覆盖
SCRIPT_NAME="${SCRIPT_NAME:-$(basename "$0" .sh)}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/${SCRIPT_NAME}_$(date +%Y%m%d).log}"
mkdir -p "$LOG_DIR"

# 写日志同时回显终端
_log() {
    local lv=$1; shift
    local line="[$(date '+%F %T')] [$lv] $*"
    echo "$line" >> "$LOG_FILE"
    echo "$line"
}
log_info()  { _log INFO  "$@"; }
log_warn()  { _log WARN  "$@"; }
log_error() { _log ERROR "$@"; }

must_root() {
    (( EUID == 0 )) || { log_error "需要 root 权限执行"; exit 1; }
}

ensure_dir() { [[ -d "$1" ]] || mkdir -p "$1"; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || { log_error "缺少依赖命令: $1"; exit 1; }
}

# 告警通道: 优先 webhook(钉钉/企微), 降级邮件, 再降级仅日志
# 配置环境变量:
#   ALERT_WEBHOOK  - 钉钉/企微机器人地址
#   ALERT_MAIL_TO   - 邮件收件人
send_alert() {
    local subject=$1 body=${2:-无正文}
    local content="[$(hostname)] $subject"$'\n'"$body"

    if [[ -n "${ALERT_WEBHOOK:-}" ]] && command -v curl >/dev/null 2>&1; then
        # 钉钉 text 格式, 企微兼容
        curl -s -o /dev/null -X POST "$ALERT_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"${content//$'\n'/\\n}\"}}" \
            && { log_info "告警已推送 webhook"; return 0; }
    fi

    if [[ -n "${ALERT_MAIL_TO:-}" ]] && command -v mail >/dev/null 2>&1; then
        echo "$body" | mail -s "$subject" "$ALERT_MAIL_TO"
        log_info "告警邮件已发送 -> $ALERT_MAIL_TO"
        return 0
    fi

    log_warn "未配置告警通道, 仅记录日志: $subject"
}

# 磁盘使用率(纯数字), 默认根分区
disk_used() {
    df -P "${1:-/}" | awk 'NR==2{gsub(/%/,"",$5); print $5}'
}
