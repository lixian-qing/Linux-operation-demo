#!/bin/bash
# ECS 启动时 cloud-init 执行, 装 Nginx + PHP-FPM
set -e
dnf install -y nginx php-fpm php-mysqlnd
systemctl enable --now nginx php-fpm
echo "<h1>ops-web $(hostname)</h1>" > /usr/share/nginx/html/index.html
systemctl disable --now firewalld 2>/dev/null || true
