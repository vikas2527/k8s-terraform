variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where k8s masters will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs to launch masters in"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for k8s master (baked by Packer)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for k8s master"
  type        = string
  default     = "t3.medium"
}

variable "instance_count" {
  description = "Number of master nodes (1 for dev, 3 for prod)"
  type        = number
  default     = 1
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

variable "vpc_cidr" {
  description = "VPC CIDR block — allowed for internal cluster communication"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into master nodes"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}