output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_subnets" {
  value = module.network.private_subnets
}

output "alb_arn" {
  value = module.load_balancer.alb_arn
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}

output "app_private_ips" {
  value       = module.app.app_private_ips
  description = "Private IPs of the app instances (from app module)"
}

