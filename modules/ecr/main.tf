locals {
  common_tags = merge(
    {
        Project = var.project_name
        Environment = var.environment
        ManagedBy = "terraform"
    },
    var.tags
  )
}

# ── ECR Repositories ──────────────────────────────────────────────────────────

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repository_names)

  name = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags,{
    Name = each.value
  })
}

# ── Lifecycle Policy (keep only last N images) ────────────────────────────────

resource "aws_ecr_lifecycle_policy" "this" {
    for_each = aws_ecr_repository.this
    repository = each.value.name
    
    policy = jsondecode({
        rules = [
            {
                rulePriority = 1
                description  = "Keep last ${var.max_image_count} images"
                selection = {
                tagStatus   = "any"
                countType   = "imageCountMoreThan"
                 countNumber = var.max_image_count
            }

            action = {
                type = "expire"
            }

            
            }
        ]
    })
}