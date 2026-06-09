locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.role}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = var.role
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

