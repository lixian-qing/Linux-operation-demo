#!/bin/bash
# CentOS Stream 9 一键部署 Zabbix 6.0 LTS (服务端+Web+Agent)
# 数据库用 MariaDB(系统自带, 兼容 MySQL), Web 用 Nginx
# 凭据走环境变量, 不硬编码:
#   DB_ROOT_PASSWORD   MariaDB root 密码
#   ZABBIX_DB_PASSWORD zabbix 库密码
# 用法: sudo DB_ROOT_PASSWORD=xxx ZABBIX_DB_PASSWORD=yyy ./install_zabbix.sh
set -euo pipefail

SCRIPT_NAME=install_zabbix
source "$(dirname "$0")/../scripts/common_func.sh"
must_root

: "${DB_ROOT_PASSWORD:?请设置 DB_ROOT_PASSWORD}"
: "${ZABBIX_DB_PASSWORD:?请设置 ZABBIX_DB_PASSWORD}"

repo="https://repo.zabbix.com/zabbix/6.0/rhel/9/x86_64/zabbix-release-6.0-4.el9.noarch.rpm"

log_info "部署 Zabbix 6.0 LTS"

# 关 SELinux/防火墙(实验环境)
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl disable --now firewalld || true

rpm -Uvh "$repo"
dnf clean all
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf \
    zabbix-sql-scripts zabbix-agent mariadb-server

systemctl enable --now mariadb
# MariaDB 初始无 root 密码, 设一个
mysqladmin -u root password "$DB_ROOT_PASSWORD" 2>/dev/null || true

mysql -uroot -p"$DB_ROOT_PASSWORD" <<SQL
create database if not exists zabbix character set utf8mb4 collate utf8mb4_bin;
create user if not exists 'zabbix'@'localhost' identified by '${ZABBIX_DB_PASSWORD}';
grant all on zabbix.* to 'zabbix'@'localhost';
set global log_bin_trust_function_creators = 1;
SQL

log_info "导入 schema (约1-3分钟)"
zcat /usr/share/doc/zabbix-sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -uzabbix -p"$ZABBIX_DB_PASSWORD" zabbix

mysql -uroot -p"$DB_ROOT_PASSWORD" -e "set global log_bin_trust_function_creators = 0;"

sed -i "s/^# DBPassword=.*/DBPassword=${ZABBIX_DB_PASSWORD}/" /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server zabbix-agent nginx php-fpm
systemctl enable zabbix-server zabbix-agent nginx php-fpm

log_info "部署完成"
log_info "Web: http://<IP>/zabbix  账号 Admin/zabbix (首次登录请改密码)"
