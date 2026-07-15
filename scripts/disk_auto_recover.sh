#!/bin/bash
# 磁盘使用率超过85%自动清理30天过期日志自愈脚本
DISK_THRESHOLD=85
# 获取根分区使用率
disk_used=$(df -h / | grep / | awk '{print $5}' | sed 's/%//g')
if [ ${disk_used} -gt ${DISK_THRESHOLD} ];then
    echo "磁盘使用率超过${DISK_THRESHOLD}%，开始清理过期日志"
    # 清理30天Nginx访问日志
    find /var/log/nginx -type f -mtime +30 -delete
    # 清理30天MySQL慢日志
    find /var/lib/mysql/log -type f -mtime +30 -delete
    # 发送自愈告警邮件
    echo "磁盘自动清理完成，当前磁盘使用率：$(df -h / | grep / | awk '{print $5}')" | mail -s "磁盘自愈告警" admin@xxx.com
fi
