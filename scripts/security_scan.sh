#!/bin/bash
# CIS安全基线扫描脚本
echo "===== 弱密码/空密码账号检测 ====="
awk -F: '($2=="")||($2~/123456|root|admin/) {print "风险账号："$1}' /etc/shadow
echo "===== 全网开放高危端口检测 ====="
ss -tulpn | grep -E "3306|22|3389|6379|3306" | grep "0.0.0.0"
echo "===== 777权限不安全定时任务 ====="
find /etc/cron* -perm 777
echo "===== SELinux状态检查 ====="
getenforce
