# ── Network Load Balancer ─────────────────────────────────────────────────────

resource "aws_lb" "this" {
  name               = "${local.name_prefix}"
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}"
  })
}

# ── Target Group — K8s API server (port 6443) ─────────────────────────────────

resource "aws_lb_target_group" "api" {
  name     = "${local.name_prefix}-api-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 6443
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-tg"
  })
}

# ── Target Group — Ingress (port 443) ─────────────────────────────────────────

resource "aws_lb_target_group" "ingress" {
  name     = "${local.name_prefix}-ingress-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 443
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ingress-tg"
  })
}

# ── Register master instances to API target group ─────────────────────────────

resource "aws_lb_target_group_attachment" "api" {
  count            = length(var.master_instance_ids)
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = var.master_instance_ids[count.index]
  port             = 6443
}

# ── Listener — port 6443 → API target group ───────────────────────────────────

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.this.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-listener"
  })
}

# ── Listener — port 443 → ingress target group ────────────────────────────────

resource "aws_lb_listener" "ingress" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ingress-listener"
  })
}

# ── Attach ASG workers to ingress target group ────────────────────────────────

resource "aws_autoscaling_attachment" "ingress" {
  count                  = var.worker_asg_name != "" ? 1 : 0
  autoscaling_group_name = var.worker_asg_name
  lb_target_group_arn    = aws_lb_target_group.ingress.arn
}