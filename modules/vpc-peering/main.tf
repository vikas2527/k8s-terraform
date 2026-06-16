locals {
  name_prefix = "${var.project_name}-${var.environment}-vpc-peering"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ── VPC Peering Connection ────────────────────────────────────────────────────

resource "aws_vpc_peering_connection" "this" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  auto_accept = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}"
    Side = "requester"
  })
}

# ── Route — requester VPC → accepter VPC ─────────────────────────────────────
# Allows traffic from shared VPC to reach dev/prod VPC

resource "aws_route" "requester_to_accepter" {
  route_table_id            = var.requester_route_table_id
  destination_cidr_block    = var.accepter_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# ── Route — accepter VPC → requester VPC ─────────────────────────────────────
# Allows traffic from dev/prod VPC to reach shared VPC (Jenkins)

resource "aws_route" "accepter_to_requester" {
  route_table_id            = var.accepter_route_table_id
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}