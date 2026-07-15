#!/bin/bash
#日志清除脚本
#清理系统前7天日志
find /var/log -type f -name "*.log" -mtime +7 -truncate
#清理项目本地日志
find ./logs -type f -mtime +3 -delete
echo "日志清理执行完毕"

