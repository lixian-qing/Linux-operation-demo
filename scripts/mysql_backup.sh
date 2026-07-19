#!/bin/bash
# MySQL 全库逻辑备份 -> 压缩 -> 生成 md5 -> 清理过期
# 凭据: 优先 ~/.my.cnf, 其次环境变量 MYSQL_ROOT_PASSWORD
# crontab: 0 2 * * * /path/mysql_backup.sh
set -euo pipefail

SCRIPT_NAME=mysql_backup
source "$(dirname "$0")/common_func.sh"
need_cmd mysqldump
ensure_dir "$BACKUP_DIR"

ts=$(date +%Y%m%d_%H%M)
sql="$BACKUP_DIR/all_db_${ts}.sql"
gz="$BACKUP_DIR/all_db_${ts}.tar.gz"
keep=${MYSQL_BACKUP_KEEP_DAYS:-7}

dump_args=(-u root)
if [[ -f ~/.my.cnf ]]; then
    : # 走客户端配置, 不在命令行暴露密码
elif [[ -n "${MYSQL_ROOT_PASSWORD:-}" ]]; then
    dump_args+=("-p${MYSQL_ROOT_PASSWORD}")
else
    log_error "未配置凭据: 放 ~/.my.cnf 或 export MYSQL_ROOT_PASSWORD"
    exit 1
fi

log_info "开始备份 -> $gz"

if ! mysqldump "${dump_args[@]}" --all-databases --single-transaction \
        --routines --triggers --default-character-set=utf8mb4 > "$sql" 2>>"$LOG_FILE"; then
    log_error "mysqldump 失败"
    send_alert "MySQL备份失败" "mysqldump 执行失败, 详见 $LOG_FILE"
    rm -f "$sql"
    exit 1
fi

tar -zcf "$gz" -C "$BACKUP_DIR" "$(basename "$sql")"
rm -f "$sql"

# 校验文件, 生成 md5 便于异地校验完整性
md5sum "$gz" > "${gz}.md5"

find "$BACKUP_DIR" -name "all_db_*.tar.gz*" -mtime +"$keep" -delete
log_info "备份完成: $gz (保留 ${keep} 天)"
