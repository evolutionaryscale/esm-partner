##########################################
# Provider & Workspace Setup
##########################################
provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

terraform {
  backend "s3" {
    # config in backend.config
  }
}

##########################################
# Variables
##########################################
variable "project_name" {
  description = "Project name for resource naming, e.g., esm-partner"
  type        = string
  default     = "esm-partner"
}

# Note: Terraform workspaces can be used to separate state for different environments
# e.g., terraform workspace new dev, terraform workspace new prod

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-2"
}

variable "iam_role_name_prefix" {
  description = "Prefix for naming IAM roles"
  type        = string
  default     = "esm"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev",
    Project     = "esm-partner"
  }
}


# These data sources provide information about the environment this
# terraform is running in -- it's how we can know which account, region,
# and partition (ie, commercial AWS vs GovCloud) we're in.

data "aws_caller_identity" "current" {}

output "caller_account_id" {
  description = "The AWS account ID in which Terraform is running."
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "The ARN of the AWS identity running Terraform."
  value       = data.aws_caller_identity.current.arn
}

output "caller_user_id" {
  description = "The user ID of the AWS identity running Terraform."
  value       = data.aws_caller_identity.current.user_id
}
