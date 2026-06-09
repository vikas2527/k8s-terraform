output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "public_ips" {
  description = "List of public IP addresses (if in public subnet)"
  value       = aws_instance.this[*].public_ip
}

output "security_group_id" {
  description = "Security group ID attached to the instances"
  value       = aws_security_group.this.id
}