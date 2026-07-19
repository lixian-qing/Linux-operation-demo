# 阿里云基础设施 Terraform

一键编排 VPC / 安全组 / ECS / SLB。

## 使用
```bash
# 1. 配置凭据(环境变量, 不入文件)
export ALICLOUD_ACCESS_KEY=xxx
export ALICLOUD_SECRET_KEY=xxx

# 2. 填参数
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# 3. 初始化并预览
terraform init
terraform plan

# 4. 创建
terraform apply

# 用完销毁, 避免持续扣费
terraform destroy
```

## 资源说明
- VPC 10.0.0.0/16 + 交换机 10.0.1.0/24
- 安全组放行 22/80/443/10050/10051
- ECS 按量付费, user_data.sh 启动时自动装 Nginx/PHP
- SLB TCP 80 转发到 ECS 80

## 注意
- ECS 按量计费, 演示完务必 destroy
- terraform.tfvars 含密码, 已被 .gitignore 忽略, 不要提交
