# esm-partner Terraform Module

This Terraform module deploys SageMaker resources for the ESM models. It creates:
- An IAM role for SageMaker with the necessary permissions.
- SageMaker models, endpoint configurations, and endpoints based on a model catalog.
- Unique resource naming via a random suffix for easier identification.

## Features

- **Multi-Model Support:**  
  Define a catalog of models in a `models.yaml` file and select which ones to deploy via a map variable (`selected_models`).

- **Parameterization:**  
  Customize instance types, counts, and naming via input variables.

- **Unique Resource Identification:**  
  Each deployment is assigned a unique suffix to avoid collisions and ease identification.

## Usage

Example usage in a Terraform configuration:

```hcl
module "esm_partner" {
  source = "git::https://github.com/evolutionaryscale/esm-partner.git?ref=v1.0.0"

  selected_models = {
    "prototype_model" = {
      selector       = "ESMC-300M"
      instance_type  = "ml.g5.2xlarge"
      instance_count = 1
    },
    "performance_model" = {
      selector       = "ESMC-300M"
      instance_type  = "ml.g5.4xlarge"
      instance_count = 1
    },
    "test_model" = {
      selector       = "ESMC-600M"
      instance_type  = "ml.g6e.4xlarge"
      instance_count = 1
    }
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
```