# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.region
# }

###########################
# Variables
###########################
variable "endpoint_name" {
  description = "Name for the SageMaker endpoint."
  type        = string
  default     = "Endpoint-ESMC-300M-1"
}

variable "execution_role_arn" {
  description = "ARN of the SageMaker execution role."
  type        = string
  default     = "arn:aws:iam::577638386256:role/service-role/SageMaker-ExecutionRole-20250312T154511"
}

variable "model_package" {
  description = "ARN of the model package."
  type        = string
  default     = "arn:aws:sagemaker:us-east-2:057799348421:model-package/esmc-300m-2024-12-6ad677e3dc243fb1b56e5787b7f93b53"
}

variable "instance_type" {
  description = "Instance type for the endpoint."
  type        = string
  default     = "ml.g5.2xlarge"
}

variable "instance_count" {
  description = "Initial instance count for the endpoint."
  type        = number
  default     = 1
}

# variable "region" {
#   description = "AWS region to deploy."
#   type        = string
#   default     = "us-east-2"
# }

###########################
# SageMaker Model
###########################
resource "aws_sagemaker_model" "model" {
  name                   = "Model-ESMC-300M-1"
  execution_role_arn     = var.execution_role_arn
  enable_network_isolation = true

  primary_container {
    model_package_name = var.model_package
  }
}

###########################
# SageMaker Endpoint Configuration
###########################
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "EndpointConfig-ESMC-300M-1"

  production_variants {
    variant_name                   = "variant-1"
    model_name                     = aws_sagemaker_model.model.name
    initial_instance_count         = var.instance_count
    instance_type                  = var.instance_type
    initial_variant_weight         = 1
    model_data_download_timeout_in_seconds = 3600
  }
}

###########################
# SageMaker Endpoint
###########################
resource "aws_sagemaker_endpoint" "endpoint" {
  name        = var.endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.endpoint_config.name
}

###########################
# Outputs
###########################
output "model_name" {
  description = "Name of the SageMaker Model."
  value       = aws_sagemaker_model.model.name
}

output "endpoint_url" {
  description = "Endpoint invocation URL. Use this only after the endpoint is InService."
  value       = "https://runtime.sagemaker.${var.region}.amazonaws.com/endpoints/${var.endpoint_name}/invocations"
}

output "endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration."
  value       = aws_sagemaker_endpoint_configuration.endpoint_config.name
}

output "endpoint_name" {
  description = "Name of the SageMaker endpoint."
  value       = aws_sagemaker_endpoint.endpoint.name
}
