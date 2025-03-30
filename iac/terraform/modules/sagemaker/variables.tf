variable "selected_models" {
  description = "Map of selected models for deployment. Each key defines a deployment, and the value specifies the model selector and optional overrides."
  type = map(object({
    selector       = string
    instance_type  = optional(string)
    instance_count = optional(number)
  }))
}

variable "iam_role_name_prefix" {
  description = "Prefix for naming IAM roles."
  type        = string
  default     = "esm"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "esm-partner"
  }
}

variable "region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-2"
}