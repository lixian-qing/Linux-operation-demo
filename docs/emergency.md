# 服务器入侵应急响应

思路: 保留现场 -> 控制损失 -> 取证 -> 清除 -> 加固 -> 复盘。不要急于重启。

## 1. 隔离现场
```bash
# 断外网保内网(方便取证), 不重启
ip link set ens33 down
date; uptime; who; last | head
```

## 2. 取证
```bash
dir=/forensic/$(date +%Y%m%d); mkdir -p $dir
cp /var/log/secure /var/log/messages /var/log/audit/audit.log $dir/ 2>/dev/null
cp -r /var/log/nginx $dir/ 2>/dev/null
ss -antlp > $dir/net.txt
ps auxf > $dir/proc.txt
```

## 3. 排查后门
```bash
# UID=0 的非 root 账号
awk -F: '$3==0{print}' /etc/passwd
# 可疑 SSH 公钥
cat /root/.ssh/authorized_keys
# SUID 后门
find / -perm -4000 -type f 2>/dev/null
# 恶意定时任务
cat /etc/crontab; cat /var/spool/cron/* 2>/dev/null
```

## 4. 查 Web 木马
```bash
find /usr/share/nginx/html -type f \( -name "*.php" -o -name "*.sh" \) -mtime -7
grep -rEn 'eval|base64_decode|shell_exec|system\(' /usr/share/nginx/html --include=*.php
```

## 5. 清除与重置
```bash
kill -9 <PID>            # 确认后再杀
passwd root
mysql -uroot -p -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';"
# 清理恶意文件与定时任务
```

## 6. 加固
```bash
dnf update -y
./scripts/security_baseline.sh    # 基线复检
# 收紧防火墙, 更新 Zabbix 告警阈值
```

## 7. 复盘
出报告(时间线/入口/影响/处置), 优化监控告警, 缩短发现时间。
