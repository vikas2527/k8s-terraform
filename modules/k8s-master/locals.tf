locals {
  name_prefix = "${var.project_name}-${var.environment}-k8s-master"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = "k8s-master"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}