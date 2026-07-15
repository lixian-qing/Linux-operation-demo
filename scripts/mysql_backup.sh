#!/bin/bash
# mysql自动备份脚本
BACKUP_DIR="/data/mysql_back"
DATE=$(date+ %Y%m%d_%H%M)
mkdir -p $BACKUP_DIR

mysqldump -uroot --all-databases > $BACKUP_DIR/all_db_$DATE.sql tar -zcvf $BACKUP_DIR/all_db_$DATE.tar.gz $BACKUP_DIR/all_db_$DATE.sql rm -f $BACKUP_DIR/all_db_$DATE.sql


find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete echo "数据备份完成: $BACKUP_DIR/all_db_$DATE.tar.gz"
