variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where devtools will be launched"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch devtools in (use private subnet)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for devtools EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for devtools"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into devtools"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}