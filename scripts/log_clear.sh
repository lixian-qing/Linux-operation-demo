#!/bin/bash
find /var/log -type f -name "*.log" -mtime +7 -truncate
find ./logs -type f -mtime +3 -delete
echo "日志清理执行完毕"
