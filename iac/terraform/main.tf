terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.93.0, < 6.0.0"
    }
  }
}
#   default_tags {
#     # tags = var.tags
#     tags = {
#       Environment = "dev"
#       Project     = "esm-partner"
#     }
#   }
# }

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
    #   instance_type  = "ml.g5.4xlarge"
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
}

output "sagemaker_endpoints" {
  description = "Deployed SageMaker endpoints from the module."
  value       = module.esm_partner.sagemaker_endpoints
}

output "sagemaker_execution_role" {
  description = "Name of the SageMaker IAM execution role."
  value       = module.esm_partner.sagemaker_execution_role
}