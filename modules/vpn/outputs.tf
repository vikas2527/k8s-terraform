output "instance_id" {
  description = "VPN EC2 instance ID"
  value       = aws_instance.vpn.id
}

output "public_ip" {
  description = "VPN server public IP (Elastic IP) — connect your VPN client to this"
  value       = aws_eip.vpn.public_ip
}

output "private_ip" {
  description = "VPN server private IP"
  value       = aws_instance.vpn.private_ip
}

output "security_group_id" {
  description = "VPN security group ID"
  value       = aws_security_group.vpn.id
}