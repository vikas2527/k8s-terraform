# ── Security Group ────────────────────────────────────────────────────────────

resource "aws_security_group" "vpn" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for OpenVPN server"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # OpenVPN UDP
  ingress {
    description = "OpenVPN UDP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OpenVPN TCP (fallback)
  ingress {
    description = "OpenVPN TCP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# ── Elastic IP — VPN needs a stable public IP ─────────────────────────────────

resource "aws_eip" "vpn" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-eip"
  })
}

# ── EC2 Instance ──────────────────────────────────────────────────────────────

resource "aws_instance" "vpn" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.vpn.id]

  # Required for VPN — instance must be able to forward packets
  source_dest_check = false

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    vpn_client_cidr = var.vpn_client_cidr
    vpc_cidr        = var.vpc_cidr
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}"
  })
}

# ── Associate Elastic IP to VPN instance ──────────────────────────────────────

resource "aws_eip_association" "vpn" {
  instance_id   = aws_instance.vpn.id
  allocation_id = aws_eip.vpn.id
}