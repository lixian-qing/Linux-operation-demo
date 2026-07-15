nux服务器自动化巡检脚本 运维求职项目
LOG_FILE="./logs/check_$(date +%Y%m%d).log"
mkdir -p ./logs

echo "====================服务器巡检报告 $(date)====================" >> $LOG_FILE
echo "【1.系统基础信息】" >> $LOG_FILE
hostname
uname -r
cat /etc/centos-release

echo -e "\n【2.CPU负载】" >> $LOG_FILE
uptime

echo -e "\n【3.内存使用】" >> $LOG_FILE
free -h

echo -e "\n【4.磁盘使用率】" >> $LOG_FILE
df -h | grep -v tmpfs

echo -e "\n【5.监听端口】" >> $LOG_FILE
ss -ltnp

echo -e "\n【6.当前登录用户】" >> $LOG_FILE
who
echo "============================================================" >> $LOG_FILE
Echo "巡检完成，日志输出至 $LOG_FILE"
