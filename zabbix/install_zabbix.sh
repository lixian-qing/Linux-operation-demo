#!/bin/bash
set -e
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
dnf install -y mariadb mariadb-server httpd php php-mysqlnd php-gd php-bcmath php-mbstring
systemctl start mariadb
mysql_secure_installation <<EOF

y
123456
123456
y
y
y
y
EOF
mysql -uroot -p123456 <<SQL
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user zabbix@localhost identified by 'Zabbix@123';
grant all on zabbix.* to zabbix@localhost;
flush privileges;
SQL
zcat /usr/share/zabbix/database/mysql.sql.gz | mysql -uzabbix -pZabbix@123 zabbix
sed -i 's/# DBPassword=/DBPassword=Zabbix@123/' /etc/zabbix/zabbix_server.conf
systemctl enable --now zabbix-server zabbix-agent httpd
echo "访问地址：http://本机IP/zabbix Admin/zabbix"
