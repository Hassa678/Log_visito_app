output "app_private_ips" {
  value       = [for instance in aws_instance.app : instance.private_ip]
  description = "Private IPs of the app instances"
}
