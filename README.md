# esm-partner

**esm-partner** is a reference repository published by [EvolutionaryScale](https://www.evolutionaryscale.ai/) for enterprise partners that provides Infrastructure as Code (IaC) and supporting documentation for deploying our ESM models. This repository is intended as a source of information, sample configurations, and best practices to help you set up and manage your own deployments. While contributions are welcome, please note that this repository is primarily a reference resource.

## Overview

This repository contains:

- **Terraform Module:**  [`terraform-aws-esm-partner`](./iac/terraform-aws-esm-partner)

  A fully parameterized Terraform module for deploying SageMaker models, endpoint configurations, and endpoints for the ESM models. The module uses a model catalog (`models.yaml`) to support multi-model deployments and includes optional support for creating a shared service account for endpoint access.

- **Examples:**

  Example Terraform configurations demonstrating:

  - A basic single-model deployment.
  - A deployment with a shared service account.
  - A multi-model deployment.
  
  See the [examples](./iac/terraform-aws-esm-partner/examples) directory for usage details.

## Getting Started with this Repository

1. **Clone the Repository:**

Clone the repository and navigate to the root of the module.

  ```bash
    git clone git@github.com:evolutionaryscale/esm-partner.git
    cd esm-partner/iac/terraform-aws-esm-partner
  ```

Examples can be found in a subdirectory from here: [`examples/`](./iac/terraform-aws-esm-partner/examples/).

2. **Review the Documentation:**

  For detailed setup and usage instructions, please refer to the `terraform-aws-esm-partner` module [README](./iac/terraform-aws-esm-partner/README.md) file.

3. **Use the Terraform Module:**

  Reference our Terraform module in your own IaC configuration as demonstrated in the examples. For instance, see the [basic example](./iac/terraform-aws-esm-partner/examples/basic/) for a simple deployment setup.

  ```
  module "esm_partner" {
    source = "git@github.com:evolutionaryscale/esm-partner.git//iac/terraform-aws-esm-partner?ref=v1.0.0"

    selected_models = {
      "prototype_model" = {
        selector      = "ESMC-300M"
      }
    }
  }
  ```

## Repository Structure

### Tree
```
esm-partner/
├── iac/
│   └── terraform-aws-esm-partner/   # Terraform `esm-partner` module and code for deploying AWS cloud infrastructure.
│       ├── README.md                # Overview and usage instructions for IaC.
│       ├── *.tf                     # Module HCL code.
│       ├── models.yaml              # ESM module specification fallback configuration file.
│       └── examples/                # Example configurations demonstrating module usage.
│           ├── basic/               # Basic single-model deployment example.
│           ├── basic_shared_user/   # Example with shared service account enabled.
│           └── multi_model/         # Example showing multi-model deployments.
├── notebooks/                       # Shared notebooks.
└── README.md                        # This file.
```

## Important Notes

- **Customization & Maintenance:**

  This repository is designed to be a reference for a standardized, unified product. We encourage you to adapt the provided configurations to your own environment, and would appreciate it if you could share any changes with us that you think would be useful for the base modules.

- **License:**

  This project is licensed under the terms of the MIT license. See [LICENSE](./LICENSE.md) for details.

- **Feedback:**

  While this repository is not intended as an active collaborative development space, your feedback and suggestions for improvements are welcome. Please email if you encounter any problems or have ideas for enhancements.

## Contact

If you have any questions or suggestions, please open an issue on the GitHub repository. You can also reach me by [email](mailto:cram%40evolutionaryscale.ai).
