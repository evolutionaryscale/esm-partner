# Basic Shared User Example

This example builds on the [esm-partner Terraform Module](../../README.md) and demonstrates deploying a SageMaker endpoint **with the optional shared service account enabled**.

## Overview

In addition to deploying a SageMaker endpoint using a model from the module’s catalog (`models.yaml`), this example enables the shared service account feature. When enabled, the module creates a dedicated IAM user (with an attached policy and access keys) to be used for centralized endpoint invocation.

## What’s Different from the Basic Example

- **Shared Service Account Enabled:**  
  The module is configured with `enable_shared_service_account = true`.
- **Additional Outputs:**  
  The outputs include credentials for the shared service account:
  - `shared_service_user_name`
  - `shared_service_user_access_key_id`
  - `shared_service_user_secret_access_key` (sensitive)

For full details on the module configuration, inputs, and outputs, please see the main [README](../../README.md).

## Additional Notes

- Handle shared service account credentials securely. For production use, consider storing these values in a secrets manager.
- Adjust any variable values (e.g., in terraform.tfvars) as needed for your environment.