output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.k8s_asg_worker.name
}

output "asg_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.k8s_asg_worker.arn
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.k8s_asg_worker.id
}

output "security_group_id" {
  description = "ASG worker security group ID"
  value       = aws_security_group.k8s_asg_worker.id
}

output "iam_role_name" {
  description = "ASG worker IAM role name"
  value       = aws_iam_role.k8s_asg_worker.name
}

output "instance_profile_name" {
  description = "ASG worker IAM instance profile name"
  value       = aws_iam_instance_profile.k8s_asg_worker.name
}