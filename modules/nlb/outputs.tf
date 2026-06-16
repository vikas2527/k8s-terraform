output "nlb_arn" {
  description = "NLB ARN"
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "NLB DNS name — use this as kubeadm control-plane-endpoint"
  value       = aws_lb.this.dns_name
}

output "api_target_group_arn" {
  description = "Target group ARN for K8s API server (port 6443)"
  value       = aws_lb_target_group.api.arn
}

output "ingress_target_group_arn" {
  description = "Target group ARN for ingress (port 443)"
  value       = aws_lb_target_group.ingress.arn
}