variable "project_name" {
  description = "Project name used for resource naming"
  type = string
}

variable "environment" {
   description = "Environment name (dev, prod, shared)"
   type        = string
}

variable "repository_names" {
    description = "List of ECR repository names to create"
    type = list(string)
}

variable "max_image_count" {
  description = "Maximum number of images to keep per repository"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
