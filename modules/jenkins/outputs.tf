output "instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = module.ec2.instance_ids[0]
}

output "private_ip" {
  description = "Jenkins private IP"
  value       = module.ec2.private_ips[0]
}

output "public_ip" {
  description = "Jenkins public IP"
  value       = module.ec2.public_ips[0]
}

output "security_group_id" {
  description = "Jenkins security group ID"
  value       = module.ec2.security_group_id
}

output "iam_role_name" {
  description = "Jenkins IAM role name"
  value       = aws_iam_role.jenkins.name
}

output "instance_profile_name" {
  description = "Jenkins IAM instance profile name"
  value       = aws_iam_instance_profile.jenkins.name
}