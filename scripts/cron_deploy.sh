#!/bin/bash
# 部署定时任务, 幂等(BEGIN/END 标记块, 重复执行不堆积)
set -euo pipefail

SCRIPT_NAME=cron_deploy
source "$(dirname "$0")/common_func.sh"

sdir="$PROJECT_ROOT/scripts"
begin="# ops-project BEGIN"
end="# ops-project END"

cur=$(crontab -l 2>/dev/null || true)
# 去掉旧的标记块
cleaned=$(printf '%s\n' "$cur" | awk -v b="$begin" -v e="$end" '$0==b{f=1;next} $0==e{f=0;next} !f')

block="$begin
0 */4 * * * $sdir/server_check.sh >> $LOG_DIR/server_check.cron.log 2>&1
0 2 * * * $sdir/mysql_backup.sh >> $LOG_DIR/mysql_backup.cron.log 2>&1
0 3 * * * $sdir/log_clear.sh >> $LOG_DIR/log_clear.cron.log 2>&1
*/10 * * * * $sdir/disk_auto_recover.sh >> $LOG_DIR/disk_auto_recover.cron.log 2>&1
*/2 * * * $sdir/service_repair.sh >> $LOG_DIR/service_repair.cron.log 2>&1
$end"

printf '%s\n\n%s\n' "$cleaned" "$block" | crontab -
log_info "定时任务部署完成(幂等), crontab -l 查看"
