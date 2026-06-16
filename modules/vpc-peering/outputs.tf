output "peering_connection_id" {
  description = "VPC peering connection ID"
  value       = aws_vpc_peering_connection.this.id
}

output "peering_connection_status" {
  description = "VPC peering connection status"
  value       = aws_vpc_peering_connection.this.accept_status
}