variable "models_yaml_path" {
  description = "Path to the models YAML configuration file. (Defaults to current directory.)"
  type        = string
  default     = "models.yaml"
}

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

variable "enable_shared_service_account" {
  description = "Enable creation of a shared service account for accessing SageMaker endpoints."
  type        = bool
  default     = false
}

variable "shared_service_account_name" {
  description = "Optional: Override the default name for the shared service account."
  type        = string
  default     = ""
}
