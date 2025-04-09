# Basic Example: Deploying SageMaker Models and Endpoints

This example demonstrates how to use the **esm-partner** Terraform module to deploy a SageMaker model endpoint using the ESM Partner module.

## Overview

In this example, we deploy a single model endpoint based on a model defined in the module’s `models.yaml` catalog. The configuration will create:
- A SageMaker model, endpoint configuration, and endpoint
- (Optionally) A shared service account for endpoint invocation if enabled

The module is designed for use in a vanilla AWS account. The example uses a single deployment ("prototype_model") with the following settings:
- Model selector: `ESMC-300M`
- Instance type: `ml.g5.2xlarge`

## Prerequisites

- Terraform (v1.0 or later)
- AWS CLI installed and configured (with appropriate credentials)
- Git access to the repository containing the module
- [Subscribe to our AWS SageMaker model](../../GETTING_STARTED.md#sagemaker-model-subscription) to make it available within your AWS account
- Set up your [AWS and local environment, `model.yaml`, and deploy](../../GETTING_STARTED.md#setup-and-initial-deploy)

## Usage

1. **Clone the Repository**

   Clone the repository that contains the module and this example:
   ```bash
   git clone git@github.com:evolutionaryscale/esm-partner.git
   cd esm-partner/iac/terraform-aws-esm-partner
   ```

2.	**Review the Example Configuration**
The example configuration is defined in `esm_partner.tf`

   ```bash
   cd examples/basic
   vi models.yaml
   vi esm_partner.tf
   ```

3. **Initialize Terraform**

   Run the following command to initialize the backend and download the module:

   ```shell
   terraform init
   ```

4. **Plan and Apply**

   Preview the changes with:

   ```shell
   terraform plan
   ```

   If everything looks correct, deploy the infrastructure:

   ```shell
   terraform apply
   ```

5.	**Review Outputs**

   After applying, Terraform will output the sagemaker_endpoints map. This map includes details like the endpoint URL, endpoint configuration name, endpoint name, and the associated forge model name.

## Cleanup

When you’re finished, you can destroy the deployed resources:

   ```shell
   terraform destroy
   ```
## Additional Notes

- **Module Versioning**:

   The module is referenced via a Git URL with a specific tag (v1.0.0). In a production environment, you may pin the module version as needed.

- **Customizations**:

   To deploy additional models or adjust configurations, modify the selected_models variable accordingly in your terraform.tfvars file (or directly in the module call for testing).

- **Shared Service Account**:

   If you need to use a shared service account for endpoint invocation, ensure that enable_shared_service_account is set to true in your module call and that you adjust any associated variables accordingly.

Further Reading
- [esm-partner Terraform Module Documentation](../../README.md)
- [Terraform Documentation](https://www.terraform.io/docs)