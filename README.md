# esm-partner

**esm-partner** is a reference repository for enterprise partners that provides Infrastructure as Code (IaC) and supporting documentation for deploying EvolutionaryScale’s ESM models. This repository is intended as a source of information, sample configurations, and best practices to help you set up and manage your own deployments. While contributions are welcome, please note that this repository is primarily a reference resource and not a collaborative workspace for ongoing shared development.

## Overview

This repository contains:

- **Terraform Module:**  
  A fully parameterized Terraform module for deploying SageMaker models, endpoint configurations, and endpoints for the ESM models. The module uses a model catalog (`models.yaml`) to support multi-model deployments and includes optional support for creating a shared service account for endpoint access.

- **Examples:**  
  Example configurations demonstrating:
  - A basic single-model deployment.
  - A deployment with a shared service account.
  - A multi-model deployment.
  
  See the [examples](./iac/terraform-aws-esm-partner/examples) directory for usage details.


## Repository Structure


### Tree
```
esm-partner/
├── iac/
│   └── terraform-aws-esm-partner/   # Terraform `esm-partner` module and code for deploying AWS cloud infrastructure.
│       ├── README.md                # Overview and usage instructions for IaC.
│       ├── *.tf                     # Module HCL code.
│       ├── models.yaml              # ESM module specification configuration file.
│       └── examples/                # Example configurations demonstrating module usage.
│           ├── basic/               # Basic single-model deployment example.
│           ├── basic_shared_user/   # Example with shared service account enabled.
│           └── multi_model/         # Example showing multi-model deployments.
├── notebooks/                       # Shared notebooks.
└── README.md                        # This file.
```

## Getting Started

1. **Clone the Repository:**

  ```bash
    git clone git@github.com:evolutionaryscale/esm-partner.git
    cd esm-partner
  ```

2. **Review the Documentation:**

  For detailed setup and usage instructions, please refer to the README.md files.

3. **Use the Terraform Module:**

  Reference our Terraform module in your own IaC configuration as demonstrated in the examples. For instance, see the basic example for a simple deployment setup.

## Important Notes

- **Customization & Maintenance:**

  This repository is designed to be a reference for a standardized, unified product. We encourage you to adapt the provided configurations to your own environment, but please coordinate with us if there are changes you think would be useful for the base modules.

- **License:**

  Use of this module and associated resources is governed by separate licensing agreements with EvolutionaryScale. Please consult with your legal team if you have questions about licensing.

- **Feedback:**

  While this repository is not intended as an active collaborative development space, your feedback and suggestions for improvements are welcome. Please open an issue on GitHub if you encounter any problems or have ideas for enhancements.

## Contact

For questions or further assistance, please open an issue in this repository or contact us directly via email.

⸻

By using this repository as your reference, you can integrate and deploy EvolutionaryScale’s ESM models efficiently within your AWS environment while maintaining consistency with our core product design.

---

# License
This project is licensed under the ??? License.

# Contact
If you have any questions or suggestions, please open an issue on the GitHub repository. You can also reach me by [email](mailto:cram%40evolutionaryscale.ai).