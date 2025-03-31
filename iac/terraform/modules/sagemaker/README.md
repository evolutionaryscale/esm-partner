# esm-partner Terraform Module

This Terraform module deploys SageMaker resources for the ESM models. It provisions the following:
- An IAM role for SageMaker with the necessary permissions.
- SageMaker models, endpoint configurations, and endpoints based on a model catalog.
- Unique resource naming via a random suffix for easier identification.
- **Optional**: A shared service account for endpoint invocation, which allows a dedicated IAM user (or users) to be created for accessing the endpoints.

## Features
- **Multi-Model Support**:
Define a catalog of models in a `models.yaml` file and select which ones to deploy via a map variable (`selected_models`). This lets you deploy multiple models concurrently with custom instance settings for each.
- **Parameterization**:
Customize instance types, counts, naming, and other settings through input variables.
- **Unique Resource Identification**:
Each deployment is assigned a unique suffix to avoid collisions and to facilitate resource tracking.
- **Optional Shared Service Account**:
When enabled (via the `enable_shared_service_account` variable), the module creates a shared IAM user (or users, if extended in the future) along with an IAM policy and access keys. This account can be used to authenticate and invoke the SageMaker endpoints from a shared service account in your environment.

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

  iam_role_name_prefix          = "esm"
  environment                   = "prod"
  region                        = "us-west-1"
  tags = {
    Environment = "prod"
    Project     = "esm-partner"
  }

  enable_shared_service_account = true
  # Optionally, you can override the default shared service account name:
  # shared_service_account_name = "custom-shared-account-name"
}

output "sagemaker_endpoints" {
  description = "Deployed SageMaker endpoint details from the module."
  value       = module.esm_partner.sagemaker_endpoints
}
```

## Variables

For a full list of inputs, see `variables.tf`. Key variables include:

- **`selected_models`**:
A map of model configurations. Each key defines a deployment and includes the model selector and optional overrides for instance type and instance count.
- **`iam_role_name_prefix, environment, region, tags`**:
These are used for resource naming and tagging.
- **`enable_shared_service_account`**:
A boolean flag that enables the creation of a shared service account for invoking endpoints. When enabled, the module creates an IAM user (or accounts) with associated policies and access keys.
- **`shared_service_account_name`** (optional):
Override for the default name used for the shared service account. If not provided, a default is computed using `iam_role_name_prefix` and `environment`.

## Outputs

The module provides the following outputs:
- **`sagemaker_endpoints`**:
A map of deployed endpoint details, including the endpoint URL, endpoint configuration name, endpoint name, and the associated forge model name.
- **`sagemaker_execution_role`**:
The name of the IAM role used for SageMaker.
- **(Optional) Shared Service Account Outputs**:
When the shared service account is enabled, outputs such as the shared service IAM user’s name and access keys are available (note that sensitive values like the secret access key are marked as sensitive).

## License

Usage of this module is governed by your separate licensing agreement with EvolutionaryScale.