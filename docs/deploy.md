# LNMP+Zabbix环境部署手册
## 环境版本
系统：CentOS Stream 9
Nginx：1.20+
Mysql：5.7
Zabbix 6.0
## 一、环境初始化
1. 关闭防火墙/selinux
2. 配置yum国内镜像源
3. 安装基础依赖 gcc、vim、net-tools、ss
## 二、LNMP部署步骤
1. 安装Nginx并加载自定义安全配置
2. 部署PHP-FPM解析服务
3. 初始化MySQL数据库，配置远程访问权限
## 三、自动化脚本使用
1. ./scripts/server_check.sh 整机巡检
2. ./scripts/mysql_backup.sh 数据库定时备份
3. ./scripts/log_clear.sh 日志自动清理
## 四、阿里云配套实操
1. ECS实例创建、安全组放行端口
2. OSS对象存储静态文件托管
3. SLB负载均衡绑定后端ECS
## 五、监控部署
执行zabbix/install_zabbix.sh一键搭建监控服务
使用agent_deploy.sh批量下发监控客户端
