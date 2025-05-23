# Terraform module to create SageMaker model endpoints.
#
# This module deploys SageMaker models and endpoints based on the provided
# configuration. It also creates an IAM role for SageMaker execution and
# optionally a shared service account for accessing the endpoints.


locals {
  # Decode the models catalog from models.yaml.
  models_config = try(yamldecode(file(var.models_yaml_path)), yamldecode(file("${path.module}/models.yaml")))
  models_menu = local.models_config.models

  # Merge user-supplied selected_models with defaults from models_menu.
  final_selected_models = {
    for k, v in var.selected_models : k => {
      selector             = v.selector
      instance_type        = coalesce(v.instance_type, local.models_menu[v.selector].instance_type)
      instance_count       = coalesce(v.instance_count, local.models_menu[v.selector].instance_count)
      sagemaker_model_name = local.models_menu[v.selector].sagemaker_model_name
      endpoint_name        = local.models_menu[v.selector].endpoint_name
      model_package        = local.models_menu[v.selector].model_package
      forge_model_name     = local.models_menu[v.selector].forge_model_name
    }
  }
}

# Generate a unique suffix for each deployment.
resource "random_id" "instance_suffix" {
  for_each    = local.final_selected_models
  byte_length = 4
}

# Create the IAM role for SageMaker.
data "aws_iam_policy_document" "sagemaker_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name               = "${var.iam_role_name_prefix}-sagemaker-exec-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Create a SageMaker model for each selected model.
resource "aws_sagemaker_model" "model" {
  for_each = local.final_selected_models

  name                     = "${local.models_menu[each.value.selector].sagemaker_model_name}-${random_id.instance_suffix[each.key].hex}"
  execution_role_arn       = aws_iam_role.sagemaker_execution_role.arn
  enable_network_isolation = true

  primary_container {
    model_package_name = local.models_menu[each.value.selector].model_package
  }

  tags = var.tags
}

# Create an Endpoint Configuration for each model.
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  for_each = local.final_selected_models

  name = "EndpointConfig-${local.models_menu[each.value.selector].endpoint_name}-${random_id.instance_suffix[each.key].hex}"

  production_variants {
    variant_name                           = "variant-1"
    model_name                             = aws_sagemaker_model.model[each.key].name
    initial_instance_count                 = each.value.instance_count
    instance_type                          = each.value.instance_type
    initial_variant_weight                 = 1
    model_data_download_timeout_in_seconds = 3600
  }

  tags = var.tags
}

# Create an Endpoint for each model.
resource "aws_sagemaker_endpoint" "endpoint" {
  for_each = local.final_selected_models

  name                 = "${local.models_menu[each.value.selector].endpoint_name}-${random_id.instance_suffix[each.key].hex}"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.endpoint_config[each.key].name

  tags = var.tags
}