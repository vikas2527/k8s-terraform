variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where k8s workers will be launched"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs to launch workers in"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for k8s worker (baked by Packer)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for k8s worker"
  type        = string
  default     = "t3.medium"
}

variable "instance_count" {
  description = "Number of worker nodes"
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
  default     = 100
}

variable "vpc_cidr" {
  description = "VPC CIDR block — allowed for internal cluster communication"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into worker nodes"
  type        = list(string)
}

variable "master_security_group_id" {
  description = "Security group ID of k8s masters — workers accept traffic from it"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}