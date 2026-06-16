variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the VPN server will be launched"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID to launch the VPN server in"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the VPN EC2 instance (Ubuntu 22.04)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for VPN server"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into VPN server"
  type        = list(string)
}

variable "vpn_client_cidr" {
  description = "CIDR block assigned to VPN clients"
  type        = string
  default     = "10.8.0.0/24"
}

variable "vpc_cidr" {
  description = "VPC CIDR block — pushed to VPN clients as a route"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}