# Terraform configuration for deploying SageMaker models and endpoints
# using the ESM Partner module.

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
  # source = "git::https://github.com/evolutionaryscale/esm-partner.git?ref=v1.0.0"
  source = "./modules/sagemaker"

  selected_models = {
    "prototype_model" = {
      selector       = "ESMC-300M"
      instance_type  = "ml.g5.2xlarge"
      instance_count = 1
    },
    # "performance_model" = {
    #   selector       = "ESMC-300M"
    #   instance_type  = "ml.g5.2xlarge" # "ml.g5.4xlarge"
    #   instance_count = 1
    # },
    # "test_model" = {
    #   selector       = "ESMC-600M"
    #   instance_type  = "ml.g6e.4xlarge"
    #   instance_count = 1
    # }
  }

  iam_role_name_prefix = "esm"
  environment          = "dev"
  region               = "us-east-2"
  tags = {
    Environment = "dev"
    Project     = "esm-partner"
  }

  enable_shared_service_account = true
}

output "sagemaker_endpoints" {
  description = "Deployed SageMaker endpoints from the module."
  value       = module.esm_partner.sagemaker_endpoints
}

output "sagemaker_execution_role" {
  description = "Name of the SageMaker IAM execution role."
  value       = module.esm_partner.sagemaker_execution_role
}

output "shared_service_user_name" {
  description = "The name of the shared service IAM user, if created."
  value       = module.esm_partner.shared_service_user_name
}

output "shared_service_user_access_key_id" {
  description = "The access key ID for the shared service IAM user, if created."
  value       = module.esm_partner.shared_service_user_access_key_id
}

# TESTING ONLY: terraform output -raw shared_service_user_secret_access_key
output "shared_service_user_secret_access_key" {
  description = "The secret access key for the shared service IAM user, if created."
  value       = module.esm_partner.shared_service_user_secret_access_key
  sensitive   = true
}
