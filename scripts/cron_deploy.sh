#!/bin/bash
echo "0 2 * * * /root/ops-project/scripts/mysql_backup.sh >> /data/backup.log 2>&1" >> /var/spool/cron/root
echo "0 */4 * * * /root/ops-project/scripts/server_check.sh" >> /var/spool/cron/root
echo "0 3 * * * /root/ops-project/scripts/log_clear.sh" >> /var/spool/cron/root
echo "定时任务部署完成，查看：crontab -l"
