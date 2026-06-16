# ── IAM Role for Jenkins ──────────────────────────────────────────────────────

resource "aws_iam_role" "jenkins" {
  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

# ── IAM Policy — ECR full access ──────────────────────────────────────────────

resource "aws_iam_role_policy" "ecr" {
  name = "${local.name_prefix}-ecr-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Policy — S3 state bucket read access ──────────────────────────────────

resource "aws_iam_role_policy" "s3" {
  name = "${local.name_prefix}-s3-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Policy — EC2 describe (for dynamic inventories) ───────────────────────

resource "aws_iam_role_policy" "ec2" {
  name = "${local.name_prefix}-ec2-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Instance Profile ──────────────────────────────────────────────────────

resource "aws_iam_instance_profile" "jenkins" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.jenkins.name

  tags = local.common_tags
}

# ── EC2 Instance (calls ec2 module) ───────────────────────────────────────────

module "ec2" {
  source = "../ec2"

  project_name   = var.project_name
  environment    = var.environment
  role           = "jenkins"
  vpc_id         = var.vpc_id
  subnet_ids     = [var.subnet_id]
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  instance_count = 1
  key_name       = var.key_name
  root_volume_size     = var.root_volume_size
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs
  allowed_ui_cidrs     = var.allowed_ui_cidrs
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  tags                 = var.tags
}