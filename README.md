# esm-partner

**esm-partner** is a dedicated repository for enterprise partners to collaboratively deploy, manage, and customize cloud infrastructure and analytical tools on cloud service providers (CSPs). It provides Infrastructure as Code (IaC) and sample resources that can be easily integrated into your environment, enabling a secure, scalable, and isolated deployment that meets your IT standards while helping us maintain a unified product.

While we encourage contributions, we recognize that commercial partners may prefer to maintain private forks to protect proprietary details.

## Overview

This repository is designed to be a living, collaborative hub where our partners and internal teams can:

- **Deploy Core Infrastructure:**  
  Use parameterized Terraform configurations for VPCs, networking, IAM, SageMaker endpoints, and GPU-enabled ECS capacity providers.

- **Collaborate on Customizations:**  
  Provide a space to customize configurations in a dedicated area to minimize core product splintering.

- **Access Shared Analytical Tools:**  
  Explore and extend sample Jupyter notebooks and other resources to benchmark models and perform advanced data analysis.

## Repository Structure

- **iac/**  
  Contains Terraform for deploying the cloud infrastructure. All networking, IAM, and resource configurations are parameterized to fit your environment.
  
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
├── partners/
│   ├── partnerA/         # Partner-specific configurations and localizations.
│   └── partnerB/         # Additional partner-specific customizations.
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
└── utils/                 # Shared libraries or scripts used across modules.
```

## Partner Collaboration

We’re committed to making this repository a collaborative space:

- **Contribution Guidelines:**  
  Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to propose improvements, report issues, and submit pull requests. We understand that commercial partners may choose to work in private forks to keep their configurations confidential. Our goal is to avoid product fragmentation while ensuring a consistent core product.

- **Customization & Feedback:**  
  We encourage partners to adapt the provided configurations to their own environments and share enhancements that can benefit everyone. If you develop partner-specific customizations, please consider contributing them back (or keeping them in a designated folder within your fork) to help us maintain common standards.

- **Testing & Validation:**  
  While our internal team will run most of the automated tests (unit, integration, and end-to-end) to ensure product consistency, you are welcome to run them locally as needed. We’re working to make the testing framework as user-friendly as possible.

- **Roadmap Transparency:**  
  Our roadmap and planned improvements are documented in this repository. We welcome your input on future features and optimizations.

## Getting Started

1. Provision a new, vanilla, isolated AWS account within your organizations IT security peremitier.

2. **Install Prerequisites:**

- [tfenv](https://github.com/tfutils/tfenv)
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

(We recommend using `tfenv` to manage Terraform versions.)

3. **Clone the Repository:**
   ```bash
   git clone git@github.com:evolutionaryscale/esm-partner.git
   cd esm-partner
    ```

4.	Configure Your Environment:
- Edit the appropriate variable files (e.g., terraform.tfvars or environment-specific files) to set your deployment parameters (such as project_name, environment, and network settings). Set environment variables (such as AWS_PROFILE).
- If you are a partner, you can put your modifications into the partners/ tree, or you might choose to create a fork of this public repo and maintain your custom configurations there.

5.	Deploy the Infrastructure:
Use the provided Makefile targets (e.g., make init, make plan, and make apply) to deploy the infrastructure.

```bash
cd iac/terraform
export AWS_PROFILE=<profile_name>
make help                  # to get info on make targets
make create-state-bucket   # create tf state S3 bucket
make init                  # initialize tf state in S3
terraform plan
terraform apply            # EC2 charges start here!
```

5. Use `notebooks/ESMHelloWorldNotebook.ipynb` to verify that your SageMaker Endpoint is accessible and responding with data.

6. Explore & Customize:
- Review the sample notebooks in the notebooks/examples/ directory.
- Check the documentation in docs/ for detailed setup and usage guides.

7. **Profit!**

**Note: Creating a SageMaker Endpoint provisions a GPU-enabled EC2 instance. As a result, (1) the Terraform apply operation may take 10–20 minutes (or more) to complete, and (2) once the endpoint is active, you’ll immediately incur costs for the EC2 instance. Be sure to delete the SageMaker Endpoint when it’s no longer needed to stop these charges!**



## Cleaning up

Reverse the setup process. BEWARE: These destroy state and cannot (easily) be reversed/recovered.

```bash
cd iac/terraform
terraform plan -destroy
terraform destroy           # deconstruct infra
make destroy-state-bucket   # destroy remote tf state
make clean                  # destroy local tf state
```

All AWS configuration and state should be restored to initial conditions. It is safe to delete the dedicated AWS account.

---

# License
This project is licensed under the ??? License.

# Contact
If you have any questions or suggestions, please open an issue on the GitHub repository. You can also reach me by [email](mailto:cram%40evolutionaryscale.ai).