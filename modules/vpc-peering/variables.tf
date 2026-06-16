variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "requester_vpc_id" {
  description = "VPC ID of the requester (shared VPC)"
  type        = string
}

variable "accepter_vpc_id" {
  description = "VPC ID of the accepter (dev or prod VPC)"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "CIDR block of the requester VPC"
  type        = string
}

variable "accepter_vpc_cidr" {
  description = "CIDR block of the accepter VPC"
  type        = string
}

variable "requester_route_table_id" {
  description = "Route table ID of the requester VPC to add peering route"
  type        = string
}

variable "accepter_route_table_id" {
  description = "Route table ID of the accepter VPC to add peering route"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}