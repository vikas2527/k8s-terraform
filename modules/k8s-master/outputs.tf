output "instance_ids" {
  description = "List of k8s master instance IDs"
  value       = aws_instance.k8s_master[*].id
}

output "private_ips" {
  description = "List of k8s master private IPs"
  value       = aws_instance.k8s_master[*].private_ip
}

output "security_group_id" {
  description = "K8s master security group ID"
  value       = aws_security_group.k8s_master.id
}

output "iam_role_name" {
  description = "K8s master IAM role name"
  value       = aws_iam_role.k8s_master.name
}

output "instance_profile_name" {
  description = "K8s master IAM instance profile name"
  value       = aws_iam_instance_profile.k8s_master.name
}