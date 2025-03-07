# esm-partner

**esm-partner** is a dedicated repository for enterprise partners to collaboratively deploy, manage, and customize cloud infrastructure and analytical tools on cloud service providers (CSPs). This repository provides Infrastructure as Code (IaC) and sample resources that can be easily integrated into your environment, enabling a secure, scalable, and isolated deployment that meets your IT standards.

## Overview

This repository is designed to be a living, collaborative space where our partners and our internal teams can:

- **Deploy Core Infrastructure:**  
  Parameterized Terraform configurations for VPCs, networking, IAM, SageMaker endpoints, and GPU-enabled ECS capacity providers.
  
- **Collaborate on Customizations:**  
  Provide a structured area for partner-specific configurations, localizations, and custom scripts without interfering with our internal codebase.
  
- **Access Shared Analytical Tools:**  
  Explore and extend sample Python notebooks and other resources to benchmark models and perform advanced data analysis.

## Repository Structure

- **iac/**  
  Contains Terraform and (potentially) Pulumi code for deploying the cloud infrastructure. All networking, IAM, and resource configurations are parameterized to fit your environment.
  
- **notebooks/**  
  Contains sample and reference Jupyter notebooks designed for model testing, benchmarking, and interactive data analysis.
  
- **partners/**  
  A dedicated area for partner-specific configurations and customizations. Partners can create pull requests here to propose changes or localizations.
  
- **tests/**  
  Automated tests (unit, integration, and end-to-end) that validate infrastructure deployments and ensure the code functions as expected.
  
- **docs/**  
  Documentation including architecture diagrams, deployment guides, and best practices to help you integrate and collaborate.
  
- **ci/**  
  CI/CD pipeline configurations that automate testing, validation, and deployment workflows.
  
- **common/**  
  Shared utilities and helper scripts that can be reused across modules.


### Tree
```
/
├── iac/
│   ├── terraform/         # All Terraform code and modules.
│   ├── pulumi/            # (Future support) Alternative IaC tool code.
│   └── README.md          # Overview and usage instructions for IaC.
├── notebooks/
│   ├── examples/          # Sample notebooks and analytical tools.
│   └── docs/              # Notebook usage guides.
├── customers/
│   ├── customerA/         # Customer-specific configurations and localizations.
│   └── customerB/         # Additional customer-specific customizations.
├── tests/
│   ├── unit/              # Unit tests for individual modules.
│   ├── integration/       # Integration tests that deploy resources and run happy-path scenarios.
│   └── e2e/               # End-to-end tests to simulate complete deployments and teardowns.
├── docs/
│   ├── architecture.md    # Architecture diagrams and design decisions.
│   ├── setup.md           # Detailed setup and deployment guides.
│   └── usage.md           # User and partner documentation.
├── ci/
│   ├── pipeline.yml       # CI/CD pipeline configuration for automated testing and deployment.
│   └── scripts/           # Helper scripts for CI tasks (e.g., deployment, testing, teardown).
└── common/
    └── utils/             # Shared libraries or scripts used across iac and notebooks.
```

## Partner Collaboration

We are committed to making this repository a collaborative hub:
- **Contribution Guidelines:**  
  Please refer to our [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to propose improvements, report issues, and submit pull requests.
  
- **Feedback & Customization:**  
  We encourage partners to customize the provided configurations to suit their environment. Share your enhancements and use this space to drive common solutions.
  
- **Transparent Roadmap:**  
  Our roadmap and planned improvements are documented here, and we welcome input on future features and optimizations.

## Getting Started

1. **Install Prerequisites:**

- [tfenv](https://github.com/tfutils/tfenv)
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Use `tfenv` to install `terraform`:

```shell
tfenv install latest  # 
```

2. **Clone the Repository:**
   ```bash
   git clone git@github.com:evolutionaryscale/esm-partner.git
   cd esm-partner
    ```
3. **Profit!**

---

# License
This project is licensed under the ??? License.

# Contact
If you have any questions or suggestions, please open an issue on the GitHub repository. You can also reach me by [email](mailto:cram%40evolutionaryscale.ai).