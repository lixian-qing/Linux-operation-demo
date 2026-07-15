#!/bin/bash
LOCAL_DIR="./static"
OSS_BUCKET="demo-bucket-lixianqing"
aliyun oss sync $LOCAL_DIR oss://$OSS_BUCKET --delete
echo "OSS同步完成"
