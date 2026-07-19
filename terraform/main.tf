# 阿里云基础设施编排: VPC / 安全组 / ECS / SLB
# 用法:
#   export ALICLOUD_ACCESS_KEY=xxx
#   export ALICLOUD_SECRET_KEY=xxx
#   cp terraform.tfvars.example terraform.tfvars && 填密码
#   terraform init && terraform plan && terraform apply

terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.21"
    }
  }
}

provider "alicloud" {
  region = var.region
  # AK/SK 走环境变量 ALICLOUD_ACCESS_KEY / ALICLOUD_SECRET_KEY, 不写进文件
}

# 取最新的 CentOS Stream 9 镜像
data "alicloud_images" "centos" {
  most_recent = true
  name_regex  = "^centos_stream_9"
  owners      = "system"
}

# VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "ops-vpc"
  cidr_block = "10.0.0.0/16"
  tags       = { Project = "ops-demo" }
}

# 交换机
resource "alicloud_vswitch" "vsw" {
  vpc_id        = alicloud_vpc.vpc.id
  cidr_block    = "10.0.1.0/24"
  zone_id       = var.zone_id
  vswitch_name  = "ops-vsw"
}

# 安全组
resource "alicloud_security_group" "sg" {
  name   = "ops-sg"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "ingress" {
  for_each          = toset(["22", "80", "443", "10050", "10051"])
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "${each.value}/${each.value}"
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

# Web 节点 ECS (按量, 演示用)
resource "alicloud_instance" "web" {
  count                     = var.instance_count
  instance_name             = "ops-web-${count.index + 1}"
  instance_type             = var.instance_type
  image_id                  = data.alicloud_images.centos.images[0].id
  vswitch_id                = alicloud_vswitch.vsw.id
  security_groups           = [alicloud_security_group.sg.id]
  system_disk_category      = "cloud_essd"
  system_disk_size          = 40
  internet_charge_type      = "PayByTraffic"
  internet_max_bandwidth_out = 5
  password                  = var.ecs_password
  user_data                 = file("${path.module}/user_data.sh")
  tags = {
    Project = "ops-demo"
    Role    = "web"
  }
}

# SLB 负载均衡 (TCP 80 转发到 ECS)
resource "alicloud_slb_load_balancer" "slb" {
  load_balancer_name   = "ops-slb"
  vswitch_id           = alicloud_vswitch.vsw.id
  internet_charge_type = "PayByTraffic"
  internet             = true
}

resource "alicloud_slb_listener" "http" {
  load_balancer_id  = alicloud_slb_load_balancer.slb.id
  protocol          = "tcp"
  backend_port      = 80
  frontend_port     = 80
  bandwidth         = 5
  health_check_type = "tcp"
}

resource "alicloud_slb_backend_server" "web" {
  load_balancer_id = alicloud_slb_load_balancer.slb.id
  dynamic "backend_servers" {
    for_each = alicloud_instance.web
    content {
      server_id = backend_servers.value.id
      weight    = 100
    }
  }
}
