#!/bin/bash
LOG_INFO(){
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [INFO] $1" >> $LOG_FILE
}
LOG_WARN(){
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [WARN] $1" >> $LOG_FILE
}
LOG_ERROR(){
    echo "[$(date +%Y-%m-%d %H:%M:%S)] [ERROR] $1" >> $LOG_FILE
}
check_dir(){
    if [ ! -d $1 ];then
        mkdir -p $1
    fi
}
