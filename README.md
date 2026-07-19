# Linux & 阿里云综合运维实训

基于 CentOS Stream 9 的中小企业运维实战，覆盖巡检自动化、LNMP 部署、MySQL 备份、Zabbix 监控、Docker 容器化、阿里云 IaC 与对象存储，配套 CI 语法检查。

## 技术栈
- 系统：CentOS Stream 9
- 自动化：Bash（公共函数库 + 幂等定时任务）、Makefile 统一入口
- Web：Nginx、PHP-FPM
- 数据库：MySQL 5.7（Docker）/ MariaDB（Zabbix 原生，兼容 MySQL 协议）
- 容器：Docker / Docker Compose
- 监控：Zabbix 6.0 LTS
- 云：阿里云 OSS + Terraform 编排（VPC/ECS/SLB/安全组）
- CI：GitHub Actions + shellcheck

## 目录结构
```
.
├── scripts/                 # 自动化脚本(巡检/备份/清理/自愈/守护/安全)
│   ├── common_func.sh       # 公共库(日志/检查/webhook告警), 各脚本 source
│   ├── server_check.sh      # 巡检
│   ├── mysql_backup.sh      # 备份+md5校验+过期清理
│   ├── log_clear.sh         # 日志清理
│   ├── disk_auto_recover.sh # 磁盘自愈
│   ├── service_repair.sh    # 服务守护
│   ├── security_scan.sh     # 风险扫描
│   ├── security_baseline.sh # 基线合规
│   ├── oss_upload.sh        # OSS 同步
│   └── cron_deploy.sh       # 幂等部署定时任务
├── nginx-conf/              # Nginx 虚拟主机 + 安全加固
├── docker/                  # Compose 一键 LNMP(开发/生产)
├── zabbix/                  # Zabbix 部署
│   ├── install_zabbix.sh    # 服务端一键部署
│   ├── agent_deploy.sh      # Agent 批量部署(SSH免密)
│   └── templates/linux_ops.xml  # 可导入的监控模板
├── terraform/               # 阿里云 IaC(VPC/ECS/SLB/安全组)
├── docs/                    # 部署手册 + 应急手册
├── .github/workflows/       # shellcheck CI
├── Makefile                 # 统一入口
└── .gitignore
```

## 快速开始
```bash
git clone https://github.com/lixian-qing/ops-project.git
cd ops-project
chmod +x scripts/*.sh zabbix/*.sh

# 统一入口(推荐)
make help            # 看所有命令
sudo make check      # 巡检
sudo make deploy     # 部署定时任务

# 或直接跑
sudo ./scripts/server_check.sh

# Docker LNMP
cd docker && cp .env.example .env && vim .env
docker compose up -d            # 开发
docker compose -f prod-compose.yml up -d   # 生产
```

## 配置说明
密码/凭据统一走环境变量或 `.env`，不入库：

| 变量 | 用途 | 配置位置 |
|------|------|----------|
| `MYSQL_ROOT_PASSWORD` | MySQL root 密码 | docker/.env |
| `DB_ROOT_PASSWORD` | MariaDB root 密码(Zabbix) | 运行 install_zabbix.sh 时传 |
| `ZABBIX_DB_PASSWORD` | Zabbix 库密码 | 运行 install_zabbix.sh 时传 |
| `ALERT_WEBHOOK` | 钉钉/企微机器人地址 | 系统/crontab |
| `ALERT_MAIL_TO` | 告警邮件收件人 | 系统/crontab |
| `MYSQL_BACKUP_KEEP_DAYS` | 备份保留天数(默认7) | 系统 |
| `OSS_BUCKET` | OSS 桶名 | 系统 |
| `ALICLOUD_ACCESS_KEY` | 阿里云 AK(terraform) | 环境 |
| `ALICLOUD_SECRET_KEY` | 阿里云 SK(terraform) | 环境 |

MySQL 备份优先读 `~/.my.cnf`，其次读 `MYSQL_ROOT_PASSWORD`。

## 阿里云 IaC
```bash
cd terraform
export ALICLOUD_ACCESS_KEY=xxx
export ALICLOUD_SECRET_KEY=xxx
cp terraform.tfvars.example terraform.tfvars && vim terraform.tfvars
terraform init && terraform plan && terraform apply
```

## CI
提交到 GitHub 时，`.github/workflows/shellcheck.yml` 自动对 scripts/ 和 zabbix/ 跑 shellcheck。

## 配套
- 阿里云云计算产品线上实训
- Linux 下 Git 版本管理
