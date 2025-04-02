# Example Terraform configuration for deploying SageMaker models and
# endpoints using the ESM Partner module.

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "esm-partner"
    }
  }
}

module "esm_partner" {
  source = "git@github.com:evolutionaryscale/esm-partner.git//iac/terraform-aws-esm-partner?ref=v1.0.0"

  # Select the models to deploy. Each entry in the map corresponds to a
  # model deployment configuration. The key is a logical name for the
  # deployment, and the value is an object containing the model selector (and,
  # optionally, instance type and count). The selector must match a model
  # defined in the `models_menu` of the included models.yaml file. The
  # instance_type must match one of the instance types supported by the model.
  selected_models = {
    "prototype_model" = {
      selector      = "ESMC-300M"
      instance_type = "ml.g5.2xlarge"
    },
    "performance_model" = {
      selector      = "ESMC-300M"
      instance_type = "ml.g5.4xlarge"
    }
  }

  # Varibles for IAM roles and environment
  # iam_role_name_prefix = "esm"
  # environment          = "prod"
  # region               = "us-west-2"
  # tags = {
  #   Environment = "prod"
  #   Project     = "esm-partner"
  # }

  # Enable the shared service account for invoking SageMaker endpoints.
  # enable_shared_service_account = true
}

# Outputs for the deployed SageMaker models and endpoints. Values
# needed to access the ESM API include: endpoint_name, endpoint_url, 
# forge_model_name.
output "sagemaker_endpoints" {
  description = "Deployed SageMaker endpoints from the module."
  value       = module.esm_partner.sagemaker_endpoints
}
