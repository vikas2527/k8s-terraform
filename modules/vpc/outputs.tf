output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.this.id
}

output "vpc_cidr" {
    description = "VPC CIDR BLOCK"
    value = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "List of Private Subnet ID's"
  value = aws_subnet.public[*].id
}

output "public_subnet_ids"{
    description = "List of Private Subnet ID's"
    value = aws_subnet.private[*].id
}

output "nat_gateway_id"{
    description = "nat gateway ID"
    value = aws_nat_gateway.this.id
}

output "internet_gateway_id" {
    description = "IGW ID"
    value = aws_internet_gateway.this.id
}