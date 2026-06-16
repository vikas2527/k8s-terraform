output "instance_id" {
  description = "Devtools EC2 instance ID"
  value       = module.ec2.instance_ids[0]
}

output "private_ip" {
  description = "Devtools private IP"
  value       = module.ec2.private_ips[0]
}

output "security_group_id" {
  description = "Devtools security group ID"
  value       = module.ec2.security_group_id
}

output "iam_role_name" {
  description = "Devtools IAM role name"
  value       = aws_iam_role.devtools.name
}

output "instance_profile_name" {
  description = "Devtools IAM instance profile name"
  value       = aws_iam_instance_profile.devtools.name
}