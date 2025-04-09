# terraform-aws-esm-partner

The **terraform-aws-esm-partner** module deploys SageMaker resources for EvolutionaryScale's ESM models in AWS. It creates the necessary IAM roles, SageMaker models, endpoint configurations, and endpoints using a configurable model catalog. The module also optionally provisions a shared service account for accessing the endpoints.

This module is designed to be used by partners to easily deploy and manage ESM models within their dedicated AWS environment using Infrastructure-as-Code (IaC).

## Features

- **Multi-Model Support:**  
  Use a `models.yaml` catalog to define available models and select which ones to deploy via a map variable (`selected_models`).

- **Customizable Deployments:**  
  Override instance types, counts, and naming conventions through input variables.

- **Unique Resource Identification:**  
  Resources are assigned unique suffixes (via a random_id) to avoid name collisions and ease management.

- **Optional Shared Service Account:**  
  When enabled, the module creates a shared IAM user (with an associated policy and access keys) to allow a shared service account to invoke SageMaker endpoints.

## Getting Started

Before you can deploy a model, you need to do the following as one-time setup:

- [Subscribe to our AWS SageMaker model](./SETUP_CONFIG.md#sagemaker-model-subscription) to make it available within your AWS account.
- Set up your [AWS and local environment](./SETUP_CONFIG.md#getting-started).
- Add the model to your `models.yaml` configuration file using these [detailed instructions](./SETUP_CONFIG.md#modelsyaml-configuration).

## Module Structure

### High-Level Module Structure

This diagram shows the overall structure of the module as it’s used in your root configuration:

```mermaid
flowchart TD
    A[Partner Root Terraform Module]
    A --> B["module 'esm_partner'"]
    B --> C[Endpoints Component]
    B --> D["Shared Service Account Component (Optional)"]
    
    C --> E["models.yaml (Model Catalog)"]
    C --> F[selected_models variable]
    C --> U["aws_sagemaker_execution_role"]
    F --> G[For Each Selected ESM Model Instance]
    U --> G
    G --> H["random_id (Unique Suffix)"]
    G --> I[aws_sagemaker_model]
    G --> J[aws_sagemaker_endpoint_configuration]
    G --> K[aws_sagemaker_endpoint]

    D --> L["aws_iam_user (Shared Service User)"]
    D --> M["aws_iam_policy (Invoke Policy)"]
    D --> N[aws_iam_user_policy_attachment]
    D --> O[aws_iam_access_key]
    
    B --> P[Module Outputs]
    P --> Q[sagemaker_endpoints]
    P --> R[shared_service_user_name]
    P --> S[shared_service_user_access_key_id]
    P --> T[shared_service_user_secret_access_key]
```

## Usage

Include this module in your Terraform configuration:

```hcl
# Example Terraform configuration for deploying SageMaker models and endpoints using the ESM Partner module.

module "esm_partner" {
  source ="git@github.com:evolutionaryscale/esm-partner.git//iac/terraform-aws-esm-partner?ref=v0.9.0"

  selected_models = {
    "prototype_model" = {
      selector       = "ESMC-300M"
    }
  }
}

output "sagemaker_endpoints" {
  description = "Deployed SageMaker endpoints from the module."
  value       = module.esm_partner.sagemaker_endpoints
}
```

## Inputs

The module accepts the following key variables (see variables.tf):

- **`models_yaml_path`:** The path to the models YAML configuration file, `models.yaml`. Defaults to current directory.

- **`selected_models`:**
  A map where each key is a logical name for a model deployment.

  The object should include:
    - `selector`: Must match a key in models.yaml.
    - `instance_type` (optional): Override the default instance type for the model.
    - `instance_count` (optional): Override the default instance count.

- **`iam_role_name_prefix`:**
  Prefix used for naming IAM roles and related resources.

- **`environment`:**
  Deployment environment (e.g., dev, staging, prod).

- **`region`:**
  AWS region to deploy the resources.

- **`tags` (map(string)):**
  Common tags to apply to all resources.

- **`enable_shared_service_account`:**
  Set to true to create a shared IAM user for endpoint invocation.

- **`shared_service_account_name` (optional):**
  Optional override for the default shared service account name.

## Outputs

The module exports the following outputs:

- **`sagemaker_endpoints`:**
  A map of deployed endpoint details (endpoint URL, configuration name, endpoint name, and forge model name).

- **`sagemaker_execution_role`:**
  The name of the IAM role used for SageMaker.

- **`shared_service_user_name`:**
  The name of the shared IAM user, if created (outputs an empty string if not enabled).

- **`shared_service_user_access_key_id`:**
  The user access key associated with the shared service user (outputs an empty string if not enabled).

- **`shared_service_user_secret_access_key`:**
  The secret key associated with the shared service user (sensitive, not output by default).


**NOTE: Though secret access key is marked as `sensitive` in Terraform, this is insufficient to secure the key material. By default Terraform stores output values unencrypted in its state file. You must take care to ensure that this key is handled properly (i.e., stored in a proper secrets store, by encrypting the Terraform state file).**

## Service Management

### Startup Time

It usually takes 10-15 minutes for SageMaker to complete the deployment of a new Endpoin when running `terraform apply`. Once that command succeeds, the SageMaker deployment of the model now lives on a dedicated GPU instance inside your AWS environment, and will be billed directly to your AWS account.

### Outputs

Use the `terraform output` command to get the information you need to manage the SageMaker Endpoint and authenticate using the shared service account:

```shell
% terraform output
sagemaker_endpoints = {
  "prototype_model" = {
    "endpoint_config_name" = "EndpointConfig-Endpoint-ESMC-300M-1-2df2c3dd"
    "endpoint_name" = "Endpoint-ESMC-300M-1-2df2c3dd"
    "endpoint_url" = "https://runtime.sagemaker.us-east-2.amazonaws.com/endpoints/Endpoint-ESMC-300M-1-2df2c3dd/invocations"
    "forge_model_name" = "esmc-300m-2024-12"
  }
}
shared_service_user_access_key_id = tomap({
  "esm-shared-invoke-dev" = "AKIAYM7POJJIECYZ5LJU"
})
shared_service_user_name = tomap({
  "esm-shared-invoke-dev" = "esm-shared-invoke-dev"
})
shared_service_user_secret_access_key = <sensitive>
```

### Cost Control

AWS costs are incurred continuously when the SageMaker Endpoints are configured. Use the `endpoint_name` to delete the SageMaker Endpoint and deallocate the EC2 instance(s):

```shell
aws sagemaker delete-endpoint --endpoint-name "Endpoint-ESMC-300M-1-2df2c3dd"
```

This command deletes the Endpoint (there is no way to "disable" it). Restoring the Endpoint should be as simple as rerunning your `terraform apply` command.

### Shared Service Account Authentication (Optional)

If you choose to create and use the shared service account to access your SageMaker Endpoint(s), you can find the relevant access key and secret in the Terraform output. You can insert this snippet into a Jupyter Notebook to authenticate using the shaerd service account.

1. Grab the SENSITIVE secret access key from Terraform:

  ```shell
  % terraform output -json shared_service_user_secret_access_key
  {"esm-shared-invoke-dev":"MJRULedmIbkqiYPZAd8inWwxlGpTQulgin/DgP27"}
  ```

2. Use in a Jupyter Notebook or elsewhere (being sure to take care of this secret!):

  ```python
  import os
  import boto3

  AWS_REGION="us-east-2"
  AWS_ACCESS_KEY_ID="AKIAYM7POJJIECYZ5LJU"
  AWS_SECRET_ACCESS_KEY="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"

  session = boto3.setup_default_session(
      aws_access_key_id=AWS_ACCESS_KEY_ID,
      aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
      region_name=AWS_REGION
  )
  ```

### Module Directory Tree

```
terraform-aws-esm-partner/
├── README.md                # This documentation file.
├── examples/                # Example usage configurations.
│   ├── basic/               # Example with one model endpoint.
│   ├── basic_shared_user/   # Example including a shared service account.
│   └── multi_model/         # Example demonstrating multi-model deployments.
├── main.tf                  # Main module configuration (SageMaker endpoints).
├── models.yaml              # Catalog of available models.
├── outputs.tf               # Module outputs.
├── shared_user_accounts.tf  # Resources for creating shared service accounts.
├── variables.tf             # Module input variables.
└── versions.tf              # Provider version requirements.
```


### Detailed Component Relationships

This diagram dives into how the endpoints and shared user account parts relate to each other within the module:

```mermaid
flowchart TD
    subgraph Endpoints
        A1[models.yaml] 
        A2[selected_models variable]
        A3[local.final_selected_models]
        A4["random_id (unique suffix)"]
        A5[aws_iam_role.sagemaker_execution_role]
        A6[aws_sagemaker_model]
        A7[aws_sagemaker_endpoint_configuration]
        A8[aws_sagemaker_endpoint]
    end

    subgraph SharedUserAccount ["Shared Service Account (Optional)"]
        B1["enable_shared_service_account (var)"]
        B2[Local: shared_service_account_final_name]
        B3[aws_iam_user.shared_service_user]
        B4[aws_iam_policy.shared_invoke_policy]
        B5[aws_iam_user_policy_attachment.shared_invoke_policy_attachment]
        B6[aws_iam_access_key.shared_service_access_key]
    end

    A1 --> A3
    A2 --> A3
    A3 --> A4
    A3 --> A6
    A6 --> A7
    A7 --> A8
    A5 --> A6

    B1 -- "If true" --> B2
    B2 --> B3
    B3 --> B4
    B4 --> B5
    B3 --> B6

    %% Module Outputs from both components
    A8 --> O1[Output: sagemaker_endpoints]
    A5 --> O2[Output: sagemaker_execution_role]
    B3 --> O3[Output: shared_service_user_name]
    B6 --> O4[Output: shared_service_user_access_key_id]
    B6 --> O5[Output: shared_service_user_secret_access_key]
```

## License

  This project is licensed under the terms of the MIT license. See [LICENSE](../../LICENSE.md) for details.

## Examples

See the examples in the [examples/](./examples/) directory:
- **Basic**: Deploy a simple model endpoint.
- **Basic Shared User**: Deploy a model endpoint with a shared service account.
- **Multi Model**: Deploy multiple model endpoints concurrently.

## Contributing

Contributions, improvements, and feedback are welcome. Please reach out by email to contact us.
