# Linux&阿里云综合运维实训项目
## 项目简介
基于CentOS虚拟机搭建中小企业完整运维环境，覆盖服务器巡检自动化、LNMP网站部署、MySQL备份、Zabbix监控、Docker容器化、阿里云云产品实操，全部脚本、配置开源用于初级运维求职。
## 技术栈
- 系统：CentOS Stream 9
- 自动化：Shell 运维脚本
- Web服务：Nginx、PHP-FPM
- 数据库：MySQL 5.7
- 容器：Docker / Docker Compose
- 云平台：阿里云 ECS / OSS / SLB / VPC
- 监控：Zabbix 6.0
## 仓库目录说明
- scripts/ 自动化运维脚本集合（巡检、备份、日志清理）
- nginx-conf/ Nginx虚拟主机与安全加固配置
- mysql/ 数据库备份脚本
- docker/ Docker Compose 一键LNMP部署
- zabbix/ 监控告警配置模板、批量部署脚本
- docs/ 完整部署文档、故障排查手册、应急响应方案
- .gitignore 屏蔽密钥、日志、镜像等敏感文件
## 项目核心功能
1. 全自动服务器巡检，输出CPU/内存/磁盘/端口报告，便于故障预判
2. MySQL自动全量备份+过期备份清理，规避数据丢失风险
3. Nginx安全配置，隐藏版本号、禁止非法目录访问、防护CC/XSS攻击
4. Docker容器快速搭建LNMP环境，生产级资源限制与健康检测
5. Zabbix整套监控方案，单机一键部署、批量Agent下发、多阈值邮件告警
6. 配套阿里云线上沙箱实操，实现OSS静态文件自动同步
7. 系统安全基线巡检、服务故障自动自愈、入侵应急排查流程
## 配套实训资质
阿里云云计算产品线上实训结业证书（阿里云开发者平台）
熟练使用Linux环境Git完成配置与脚本版本管理
## 使用方式
git clone https://github.com/lixian-qing/ops-project.git
cd ops-project
./scripts/server_check.sh
