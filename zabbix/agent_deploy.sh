#!/bin/bash
SERVER_IP="192.168.1.100"
HOST_LIST=(192.168.1.101 192.168.1.102 192.168.1.103)
PASS="root123456"
for host in ${HOST_LIST[*]}
do
sshpass -p $PASS ssh root@$host <<EOF
dnf install -y zabbix-agent
sed -i "s/Server=127.0.0.1/Server=$SERVER_IP/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$SERVER_IP/" /etc/zabbix/zabbix_agentd.conf
systemctl enable --now zabbix-agent
EOF
echo "$host Agent部署完成"
done
