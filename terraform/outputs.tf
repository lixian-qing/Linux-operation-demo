output "slb_public_ip" {
  description = "SLB 公网 IP"
  value       = alicloud_slb_load_balancer.slb.address
}

output "ecs_public_ips" {
  description = "ECS 公网 IP"
  value       = alicloud_instance.web[*].public_ip
}

output "vpc_id" {
  value = alicloud_vpc.vpc.id
}
