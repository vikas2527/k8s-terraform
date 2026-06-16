locals {
  name_prefix = "${var.project_name}-${var.environment}-devtools"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Role        = "devtools"
      ManagedBy   = "terraform"
    },
    var.tags
  )
}