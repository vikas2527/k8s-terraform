locals {
  name_prefix = "${var.project_name}-${var.environment}-k8s-worker"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = "k8s-worker"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}