###########################
# Variables from YAML
###########################

variable "selected_model" {
  description = "The key of the model to use from models.yaml"
  type        = string
  default     = "ESMC-300M"
}

locals {
  models       = yamldecode(file("${path.module}/models.yaml"))
  active_model = local.models["models"][var.selected_model]
}

##########################################
# IAM for SageMaker
##########################################

data "aws_iam_policy_document" "sagemaker_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "sagemaker.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name               = "${var.iam_role_name_prefix}-sagemaker-exec-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

###########################
# SageMaker Model
###########################
resource "aws_sagemaker_model" "model" {
  name                     = local.active_model.sagemaker_model_name
  execution_role_arn       = aws_iam_role.sagemaker_execution_role.arn
  enable_network_isolation = true

  primary_container {
    model_package_name = local.active_model.model_package
  }
}

###########################
# SageMaker Endpoint Configuration
###########################
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "EndpointConfig-ESMC-300M-1"

  production_variants {
    variant_name                           = "variant-1"
    model_name                             = aws_sagemaker_model.model.name
    initial_instance_count                 = local.active_model.instance_count
    instance_type                          = local.active_model.instance_type
    initial_variant_weight                 = 1
    model_data_download_timeout_in_seconds = 3600
  }
}

###########################
# SageMaker Endpoint
###########################
resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = local.active_model.endpoint_name
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
  value       = "https://runtime.sagemaker.${var.region}.amazonaws.com/endpoints/${local.active_model.endpoint_name}/invocations"
}

output "endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration."
  value       = aws_sagemaker_endpoint_configuration.endpoint_config.name
}

output "endpoint_name" {
  description = "Name of the SageMaker endpoint."
  value       = aws_sagemaker_endpoint.endpoint.name
}

output "sagemaker_execution_role" {
  description = "Name of the SageMaker IAM execution role."
  value       = aws_iam_role.sagemaker_execution_role.name
}
