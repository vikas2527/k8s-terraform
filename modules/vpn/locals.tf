locals {
  name_prefix = "${var.project_name}-${var.environment}-vpn"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = "vpn"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}