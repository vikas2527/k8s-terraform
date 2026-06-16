output "instance_ids" {
  description = "List of k8s worker instance IDs"
  value       = aws_instance.k8s_worker[*].id
}

output "private_ips" {
  description = "List of k8s worker private IPs"
  value       = aws_instance.k8s_worker[*].private_ip
}

output "security_group_id" {
  description = "K8s worker security group ID"
  value       = aws_security_group.k8s_worker.id
}

output "iam_role_name" {
  description = "K8s worker IAM role name"
  value       = aws_iam_role.k8s_worker.name
}

output "instance_profile_name" {
  description = "K8s worker IAM instance profile name"
  value       = aws_iam_instance_profile.k8s_worker.name
}