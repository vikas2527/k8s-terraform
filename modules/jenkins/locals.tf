locals {
  name_prefix = "${var.project_name}-${var.environment}-jenkins"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = "jenkins"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}