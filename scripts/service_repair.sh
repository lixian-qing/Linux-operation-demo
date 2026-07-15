#!/bin/bash
LOG_FILE="./logs/service_err.log"
if ! ss -ltnp | grep nginx;then
    systemctl restart nginx
    echo "$(date) Nginx异常重启" >> $LOG_FILE
fi
if ! ss -ltnp | grep 9000;then
    systemctl restart php-fpm
    echo "$(date) PHP-FPM异常重启" >> $LOG_FILE
fi
