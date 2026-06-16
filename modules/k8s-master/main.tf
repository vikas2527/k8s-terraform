# ── IAM Role for k8s master ───────────────────────────────────────────────────

resource "aws_iam_role" "k8s_master" {
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

# ── IAM Policy — ECR pull access ──────────────────────────────────────────────

resource "aws_iam_role_policy" "ecr" {
  name = "${local.name_prefix}-ecr-policy"
  role = aws_iam_role.k8s_master.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Policy — EC2 describe (needed by cloud-provider and kubeadm) ──────────

resource "aws_iam_role_policy" "ec2" {
  name = "${local.name_prefix}-ec2-policy"
  role = aws_iam_role.k8s_master.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcs",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:AttachVolume",
          "ec2:DetachVolume"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Instance Profile ──────────────────────────────────────────────────────

resource "aws_iam_instance_profile" "k8s_master" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.k8s_master.name

  tags = local.common_tags
}

# ── Security Group ────────────────────────────────────────────────────────────

resource "aws_security_group" "k8s_master" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for K8s master nodes"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Kubernetes API server
  ingress {
    description = "K8s API server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # etcd
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # kubelet API
  ingress {
    description = "kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # kube-scheduler
  ingress {
    description = "kube-scheduler"
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # kube-controller-manager
  ingress {
    description = "kube-controller-manager"
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # CNI — Calico BGP
  ingress {
    description = "Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # CNI — VXLAN overlay
  ingress {
    description = "VXLAN overlay"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# ── EC2 Instances ─────────────────────────────────────────────────────────────

resource "aws_instance" "k8s_master" {
  count = var.instance_count

  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_ids[count.index % length(var.subnet_ids)]
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.k8s_master.name

  vpc_security_group_ids = [aws_security_group.k8s_master.id]

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${count.index + 1}"
  })
}