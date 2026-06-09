# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "this" {
    name = "${local.name_prefix}-sg"
    description = "Security group for ${local.name_prefix}"
    vpc_id = var.vpc_id

    # SSH access
    dynamic "ingress"{
        for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] :[]
        content {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = var.allowed_ssh_cidrs
        }
    }

     # UI access (Jenkins 8080, etc.)
    dynamic "ingress" {
        for_each = length(var.allowed_ui_cidrs) > 0 ? [1] : []
        content {
          description = "UI access"
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = var.allowed_ui_cidrs
        }
    }

      # All outbound traffic

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

# ── EC2 Instances ───────────────────────────────────────────────────────

resource "aws_instance" "this" {
    count = var.instance_count

    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.subnet_ids[count.index % length(var.subnet_ids)]
    key_name = var.key_name
    iam_instance_profile = var.iam_instance_profile
    user_data = var.user_data

     vpc_security_group_ids = concat(
    [aws_security_group.this.id],
    var.extra_security_group_ids
    )

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