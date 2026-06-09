variable "project_name" {
  description = "project name used for resource naming"
  type = string
}

variable "environment" {
    description = "Environment name (dev, prod ,share)"
    type = string
}

variable "role" {
    description = "Role of Ec2 instance (jenkins, k8smaster, k8s worker, devtools)"
    type = string
}

variable "vpc_id" {
    description = "VPC ID where the instance will be launched in"
    type = string  
}

variable "subnet_ids" {
    description = "SUBNET ID where the instances will be launched in"
    type = string
}

variable "ami_id" {
    description = "AMI ID to use for the instance"
    type = string
}

variable "instance_type" {
    description = "EC2 instance type"
    type = string
}

variable "instance_count" {
    description = "number of instances to create"
    type = string
    default = "1"
}

variable "key_name" {
    description = "EC2 key pair name"
    type = string
}

variable "root_volume_size" {
    description = "Root Volume size in GB"
    type = number
    default = 50
}

variable "allowed_ssh_cidrs" {
    description = "CIDR blocks allowed to ssh UI ports (e.g. Jenkins 8080)"
    type = list(string)
    default = []
}

variable "allowed_ui_cidrs" {
  description = "CIDR blocks allowed to access UI ports (e.g. Jenkins 8080)"
  type        = list(string)
  default     = []
}


variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "extra_security_group_ids" {
  description = "Additional security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}