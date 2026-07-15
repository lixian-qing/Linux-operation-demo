#!/bin/bash
LOG_FILE="./logs/security_check.log"
echo "====安全基线检测 $(date)====" >> $LOG_FILE
awk -F: 'length($2)<6 {print "弱口令用户："$1}' /etc/shadow >> $LOG_FILE
find / -perm -4000 -type f 2>/dev/null >> $LOG_FILE
ss -ltnp | awk '{print $5}' | grep -E "3389|23|445" >> $LOG_FILE
cat /etc/crontab /var/spool/cron/* 2>/dev/null >> $LOG_FILE
echo "基线检测完成" >> $LOG_FILE
