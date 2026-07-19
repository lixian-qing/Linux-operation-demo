#!/bin/bash
# 同步本地目录到阿里云 OSS (--delete 保持一致)
# 依赖: aliyun CLI, 先 aliyun configure 配 AK/SK
# 用法: ./oss_upload.sh [本地目录] [bucket]
set -euo pipefail

SCRIPT_NAME=oss_upload
source "$(dirname "$0")/common_func.sh"
need_cmd aliyun

src=${1:-${OSS_LOCAL_DIR:-$PROJECT_ROOT/static}}
bucket=${2:-${OSS_BUCKET:-demo-bucket-lixianqing}}

[[ -d "$src" ]] || { log_error "本地目录不存在: $src"; exit 1; }

log_info "同步 $src -> oss://$bucket"
if aliyun oss sync "$src" "oss://$bucket" --delete >>"$LOG_FILE" 2>&1; then
    log_info "OSS 同步完成"
else
    log_error "OSS 同步失败"
    send_alert "OSS同步失败" "$src -> oss://$bucket"
    exit 1
fi
