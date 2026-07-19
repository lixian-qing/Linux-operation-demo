.RECIPEPREFIX = >
.PHONY: check backup deploy heal guard scan baseline oss lint clean install help

SCRIPTS := scripts

help:
>@echo "运维脚本统一入口:"
>@echo "  make check      服务器巡检"
>@echo "  make backup     MySQL 备份"
>@echo "  make deploy     部署定时任务"
>@echo "  make heal       磁盘自愈"
>@echo "  make guard      服务守护"
>@echo "  make scan       安全风险扫描"
>@echo "  make baseline   安全基线检查"
>@echo "  make oss        OSS 同步"
>@echo "  make lint       shellcheck 语法检查"
>@echo "  make clean      清理过期日志"
>@echo "  make install    安装提示"

check:
>@sudo $(SCRIPTS)/server_check.sh

backup:
>@sudo $(SCRIPTS)/mysql_backup.sh

deploy:
>@sudo $(SCRIPTS)/cron_deploy.sh

heal:
>@sudo $(SCRIPTS)/disk_auto_recover.sh

guard:
>@sudo $(SCRIPTS)/service_repair.sh

scan:
>@sudo $(SCRIPTS)/security_scan.sh

baseline:
>@sudo $(SCRIPTS)/security_baseline.sh

oss:
>@$(SCRIPTS)/oss_upload.sh

lint:
>@shellcheck -e SC1090,SC1091,SC2154,SC2034 $(SCRIPTS)/*.sh zabbix/*.sh || echo "(部分警告可忽略)"

clean:
>@find logs -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
>@echo "过期日志已清理"

install:
>@echo "LNMP Docker:  cd docker && cp .env.example .env && docker compose up -d"
>@echo "Zabbix:       sudo DB_ROOT_PASSWORD=x ZABBIX_DB_PASSWORD=y ./zabbix/install_zabbix.sh"
>@echo "阿里云IaC:    cd terraform && terraform init && terraform apply"
