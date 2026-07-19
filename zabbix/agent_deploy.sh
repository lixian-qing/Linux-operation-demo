#!/bin/bash
# 批量部署 Zabbix Agent 到多台主机
# 认证: SSH 密钥免密(先 ssh-keygen + ssh-copy-id 推公钥), 不用 sshpass 明文
# 生产建议改 Ansible 统一管理, 本脚本用于小规模/演示
# 用法: sudo ./agent_deploy.sh <server-IP> [主机列表文件]
set -euo pipefail

SCRIPT_NAME=agent_deploy
source "$(dirname "$0")/../scripts/common_func.sh"
must_root

server=${1:?用法: $0 <server-IP> [hosts文件]}
host_file=${2:-$(dirname "$0")/hosts.txt}

[[ -f "$host_file" ]] || { log_error "主机列表不存在: $host_file (参考 hosts.txt.example)"; exit 1; }

# 私钥必须存在
if [[ ! -f ~/.ssh/id_ed25519 && ! -f ~/.ssh/id_rsa ]]; then
    log_error "无 SSH 私钥, 先 ssh-keygen + ssh-copy-id 推公钥"
    exit 1
fi

ssh_opts=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -o BatchMode=yes)

log_info "批量部署 Agent, Server=$server"
ok=0; bad=0

while read -r h; do
    if [[ -z "$h" || "$h" == \#* ]]; then continue; fi
    log_info "部署 -> $h"
    if ssh "${ssh_opts[@]}" "root@$h" bash -s "$server" <<'REMOTE' 2>>"$LOG_FILE"; then
        s="$1"
        rpm -q zabbix-agent >/dev/null 2>&1 || {
            dnf install -y https://repo.zabbix.com/zabbix/6.0/rhel/9/x86_64/zabbix-release-6.0-4.el9.noarch.rpm
            dnf install -y zabbix-agent
        }
        sed -i "s/^Server=127.0.0.1/Server=${s}/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^ServerActive=127.0.0.1/ServerActive=${s}/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^Hostname=Zabbix server/Hostname=$(hostname)/" /etc/zabbix/zabbix_agentd.conf
        systemctl enable --now zabbix-agent
        systemctl restart zabbix-agent
REMOTE
        log_info "$h 部署成功"; ok=$((ok+1))
    else
        log_error "$h 部署失败(检查免密/网络/权限)"; bad=$((bad+1))
    fi
done < "$host_file"

log_info "完成: 成功 $ok / 失败 $bad"
