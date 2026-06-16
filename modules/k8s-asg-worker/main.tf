# ── IAM Role for ASG worker ───────────────────────────────────────────────────

resource "aws_iam_role" "k8s_asg_worker" {
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
  role = aws_iam_role.k8s_asg_worker.id

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

# ── IAM Policy — EC2 describe (needed by kubelet) ─────────────────────────────

resource "aws_iam_role_policy" "ec2" {
  name = "${local.name_prefix}-ec2-policy"
  role = aws_iam_role.k8s_asg_worker.id

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
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Policy — ASG describe (needed for cluster autoscaler) ─────────────────

resource "aws_iam_role_policy" "asg" {
  name = "${local.name_prefix}-asg-policy"
  role = aws_iam_role.k8s_asg_worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── IAM Instance Profile ──────────────────────────────────────────────────────

resource "aws_iam_instance_profile" "k8s_asg_worker" {
  name = "${local.name_prefix}-profile"
  role = aws_iam_role.k8s_asg_worker.name

  tags = local.common_tags
}

# ── Security Group ────────────────────────────────────────────────────────────

resource "aws_security_group" "k8s_asg_worker" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for K8s ASG worker nodes"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # kubelet API — master talks to worker kubelet
  ingress {
    description     = "kubelet API from master"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [var.master_security_group_id]
  }

  # NodePort services
  ingress {
    description = "NodePort services"
    from_port   = 30000
    to_port     = 32767
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

  # All traffic within VPC (pod-to-pod communication)
  ingress {
    description = "All internal VPC traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

# ── Launch Template ───────────────────────────────────────────────────────────

resource "aws_launch_template" "k8s_asg_worker" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.k8s_asg_worker.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.k8s_asg_worker.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ────────────────────────────────────────────────────────

resource "aws_autoscaling_group" "k8s_asg_worker" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.k8s_asg_worker.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name = "${local.name_prefix}"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}