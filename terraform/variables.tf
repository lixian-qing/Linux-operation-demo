variable "region" {
  description = "阿里云地域"
  default     = "cn-hangzhou"
}

variable "zone_id" {
  description = "可用区"
  default     = "cn-hangzhou-i"
}

variable "instance_type" {
  description = "ECS 规格"
  default     = "ecs.t6-c1m1.large"
}

variable "instance_count" {
  description = "Web 节点数量"
  default     = 1
}

variable "ecs_password" {
  description = "ECS 登录密码 (8-30位, 含大小写/数字/特殊符号)"
  type        = string
  sensitive   = true
}
