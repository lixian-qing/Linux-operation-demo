# 环境部署手册

## 版本
CentOS Stream 9 / Nginx 1.20+ / PHP-FPM 8.1 / MariaDB 10.5(或 MySQL5.7 Docker) / Zabbix 6.0

## 一、系统初始化
```bash
systemctl disable --now firewalld
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 阿里云镜像源
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.aliyun.com|g' \
    -i /etc/yum.repos.d/centos*.repo

dnf install -y gcc vim net-tools iproute curl wget bash-completion
```

## 二、裸机 LNMP
```bash
# Nginx + 安全加固配置
dnf install -y nginx
cp nginx-conf/*.conf /etc/nginx/conf.d/
nginx -t && systemctl enable --now nginx

# PHP-FPM
dnf install -y php php-fpm php-mysqlnd php-gd php-bcmath php-mbstring
systemctl enable --now php-fpm

# MariaDB
dnf install -y mariadb-server
systemctl enable --now mariadb
mysql_secure_installation

# 备份凭据(走 ~/.my.cnf, 避免 mysqldump 命令行带密码)
cat > ~/.my.cnf <<EOF
[mysqldump]
user=root
password=你的密码
EOF
chmod 600 ~/.my.cnf
```

## 三、Docker LNMP
```bash
cd docker
cp .env.example .env && vim .env
docker compose up -d                       # 开发
docker compose -f prod-compose.yml up -d   # 生产(资源限制+健康检测)
docker compose ps
```

## 四、自动化脚本
```bash
chmod +x scripts/*.sh

# 统一入口(推荐)
make help          # 所有命令
sudo make check    # 巡检
sudo make backup   # 备份
sudo make scan     # 安全扫描
sudo make deploy   # 部署定时任务

# 或直接跑
sudo ./scripts/server_check.sh
```

## 五、Zabbix 监控
```bash
# 服务端
sudo DB_ROOT_PASSWORD=xxx ZABBIX_DB_PASSWORD=yyy ./zabbix/install_zabbix.sh
# 访问 http://<IP>/zabbix  Admin/zabbix

# 导入监控模板: Web -> Configuration -> Templates -> Import -> zabbix/templates/linux_ops.xml

# Agent 批量部署(先 ssh-copy-id 推公钥)
cp zabbix/hosts.txt.example zabbix/hosts.txt && vim zabbix/hosts.txt
sudo ./zabbix/agent_deploy.sh <server-IP> zabbix/hosts.txt
```

## 六、阿里云
```bash
# OSS 同步
aliyun configure
./scripts/oss_upload.sh ./static your-bucket

# IaC 一键建云资源
cd terraform
export ALICLOUD_ACCESS_KEY=xxx
export ALICLOUD_SECRET_KEY=xxx
cp terraform.tfvars.example terraform.tfvars && vim terraform.tfvars
terraform init && terraform apply
```

## 七、定时任务
```bash
sudo ./scripts/cron_deploy.sh    # 幂等, 重复执行安全
crontab -l
```
