variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the NLB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for the NLB"
  type        = list(string)
}

variable "master_instance_ids" {
  description = "List of k8s master instance IDs to register as targets"
  type        = list(string)
}

variable "worker_asg_name" {
  description = "ASG name of k8s workers to register as targets for port 443"
  type        = string
  default     = ""
}

variable "internal" {
  description = "Set to true to create an internal NLB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}