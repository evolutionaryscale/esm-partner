# Getting Started

First you'll need to set up your AWS and local environment.

1. **Provision a New AWS Account:**

- Set up a new, isolated AWS account within your organization’s IT security framework. This ensures that your deployments are separate and meet your security and compliance requirements.

2. **Install Prerequisites:**

- **tfenv:** Install [tfenv](https://github.com/tfutils/tfenv) from GitHub to manage Terraform versions. (We recommend using `tfenv` to ensure you’re running a compatible Terraform version.)
- **Terraform CLI:** Follow the [Terraform installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
- **AWS CLI:** Install using the [AWS CLI instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

3. **Clone the Repository:**
   ```bash
   git clone git@github.com:evolutionaryscale/esm-partner.git
   cd esm-partner
    ```

4.	**Configure Your Environment:**

- Variable Overrides:

  Use the provided template file to create a local `terraform.tfvars` file in which you override variables and select your model(s):

  ```bash
  cd iac/terraform
  cp templates/terraform-tfvars.txt terraform.tfvars
  ```

  Review and customize deployment parameters by editing the `terraform.tfvars` file. This file is where you can override defaults for variables such as:

	-	set environment (e.g., `dev`, `staging`, `prod`)
	-	set region (e.g., `us-east-1`, `us-west-2`)

  Specify the model(s) you want to run by setting the `selected_models` variable. The basic config is a simple selector for one of the models defined in `models.yaml`, which will select that model and use defaults for all other config values:

  ```
  selected_models = {
    "exploratory_model" = {
      selector       = "ESMC-300M"
    }
  }
  ```

  Adding additional models to this map will bring up additional SageMaker Endpoints. Fields in `models.yaml` can also optionally be overridden using this variable.

  You can also override variables via command-line flags if needed:

  ```bash
  terraform apply -var="environment=staging"
  ```

- AWS Credentials & Profile:

  Set the `AWS_PROFILE` environment variable to match your configured profile:

  ```bash
  export AWS_PROFILE=<your_profile_name>
  ```

- Custom Partner Configurations:

  If you are a partner, you can place your custom modifications in the `partners/` directory or create a fork of this repository. This lets you maintain partner-specific settings independent of the core product.


5.	**Deploy the Infrastructure:**

  Use the provided Makefile targets (e.g., `make init`) to deploy the infrastructure.

  ```bash
  cd iac/terraform
  make help                  # to get info on make targets
  make create-state-bucket   # create tf state S3 bucket
  make init                  # initialize tf state in S3
  terraform plan
  terraform apply            # EC2 charges start here!
  ```

6. **Validate:**

- Use the sample notebook (e.g., `notebooks/ESMHelloWorldNotebook.ipynb`) to verify that your SageMaker Endpoint is accessible and responding correctly.
- Check outputs (such as the endpoint URL) from Terraform to confirm that resources were created as expected.
- Modify configurations in your terraform.tfvars file as needed and re-run terraform apply to update your environment.

7. **Explore & Customize:**

- Review the sample notebooks in the notebooks/examples/ directory.
- Check the documentation in docs/ for detailed setup and usage guides.

8. **Profit!**


## Cleaning up

Reverse the setup process. BEWARE: These commands *DESTROY STATE* and cannot necessarily be reversed/recovered.

```bash
cd iac/terraform
terraform plan -destroy
terraform destroy           # deconstruct infra
make destroy-state-bucket   # destroy remote tf state
make clean                  # destroy local tf state
```

All AWS configuration and state should be restored to initial conditions. It is safe to delete the dedicated AWS account.

# SageMaker Model Subscription

The SageMaker Model subscrption process is documented as a part of our [open source repository](https://github.com/evolutionaryscale/esm?tab=readme-ov-file#esm-c-via-sagemaker-for-commercial-use--), and is repeated here for convenience.

You will need an admin AWS access to an AWS account to follow these instructions:

1. Find the ES model version you want to subscribe to. All of our offerings are visible [here](https://aws.amazon.com/marketplace/seller-profile?id=seller-iw2nbscescndm).
2. Click the name of the model version you are interested in, review pricing information and the end user license agreement (EULA), then click "Continue to Subscribe".
3. Once you have subscribed, you should be able to see our model under your [marketplace subscriptions](https://us-east-1.console.aws.amazon.com/marketplace/home#/subscriptions).
4. Click the product name and then from the "Actions" dropdown select "Configure".
5. You will next see the "Configure and Launch" UI. Here you will find the SageMaker Model Package ARN, labeled on the page as the "Product Arn". This is the ARN you need to set up a model in the `models.yaml` file for use with Terraform.

In the case where ES is supplying you a private or custom model, we will provide the Model Package ARN directly.

---

# `models.yaml` Configuration

This file contains the model catalog that defines all the models available for deployment using the esm-partner Terraform module. You will need to supply your own `models.yaml` file to use your SageMaker Model subscription. This configuration gives you control over which models are available, and how they are deployed. It also allows you to update parameters such as instance types, model package ARNs, and more.

## File Location

The location of the active `models.yaml` file is specified using the `models_yaml_path` Terraform variable. It defaults to looking for that file in the current working directory.

```
variable "models_yaml_path" {
  description = "Path to the models YAML configuration file. (Defaults to current directory.)"
  type        = string
  default     = "models.yaml"
}
```

## File Structure

The file is in YAML format and should have the following structure:

```yaml
models:
  ESMC-300M:
    sagemaker_model_name: "Model-ESMC-300M-1"
    forge_model_name: esmc-300m-2024-12
    endpoint_name: "Endpoint-ESMC-300M-1"
    model_package: "arn:aws:sagemaker:us-east-2:057799348421:model-package/esmc-300m-2024-12-6ad677e3dc243fb1b56e5787b7f93b53"
    instance_type: "ml.g5.2xlarge"
    instance_count: 1
  ESMC-600M:
    sagemaker_model_name: "Model-ESMC-600M-1"
    forge_model_name: esmc-600m-2024-12
    endpoint_name: "Endpoint-ESMC-600M-1"
    model_package: "arn:aws:sagemaker:us-east-2:057799348421:model-package/esmc-600m-EXAMPLE"
    instance_type: "ml.g5.4xlarge"
    instance_count: 1
```

## Field Descriptions

- **`models`:** The top-level key containing a mapping of model identifiers to their deployment configuration.
- **model selector:** A human friendly name that allows you to select the model to use. You choose which model(s) to deploy by specifying selector(s) using a map variable (`selected_models`).

### For each Model (e.g., ESMC-300M)
- **`sagemaker_model_name`**: The name that will be used for the SageMaker model resource. Typically, it follows the format `Model-[Model Identifier]-[Version]`.
- **`forge_model_name`**: A shorter, simplified name used within our system (e.g., the [Forge system](https://forge.evolutionaryscale.ai), ES’s application programming interface). This is typically a lowercase version or a unique short identifier for the model.
- **`endpoint_name`**: The name that will be given to the SageMaker endpoint. It usually follows a format like `Endpoint-[Model Identifier]-[Version]` so that it is easily identifiable.
- **`model_package`**: The ARN for the model package published to AWS SageMaker. For external deployments, this will be the publicly accessible ARN (usually from a marketplace account, e.g., starting with 057799348421). For a private model, the ARN will be supplied by the ES team.
- **`instance_type`**: The default AWS instance type recommended for running the model endpoint (e.g., `ml.g5.2xlarge`). Ensure this matches the supported instance types for your model.
- **`instance_count`**: The number of instances to launch for the endpoint. Typically set to 1, but can be adjusted if load is a concern.

## Customization Guidelines
- **Updating Model Parameters**: When you update your models or wish to change the deployment defaults, modify the values accordingly:

    - Update `sagemaker_model_name` if you change the published model version.
    - Adjust `instance_type` if a different hardware is needed for better performance.
    - Change `instance_count` based on your usage or performance testing results.

- **Adding or Removing Models**: You can add additional models by creating new entries under the models key in the same format. Similarly, remove any models you do not wish to deploy.
- **File Location**: Supply the models.yaml file via the module variable (for example, using the variable models_yaml_path). If you do not supply your own file, the module falls back on the default file packaged within the module.

## Example Usage in Terraform

You select models from the "menu" provided in `models.yaml` using the `selected_models` map variable. The key of the map is a human friendly name meant to identify each deployed SageMaker Model/Endpoint instance (e.g. "`prototype_model`" or "`performance_model`"). Other than the `selector` that points to your `models.yaml` entry, which is required, you only need to specify fields that you are overriding in the Terraform configuration (e.g. `instance_type` here). Any number of models can be configured in this way.

In your Terraform configuration, you might specify:

```
module "esm_partner" {
  source         = "git@github.com:evolutionaryscale/esm-partner.git//iac/terraform-aws-esm-partner?ref=v1.0.0"
  models_yaml_path = "/path/to/your/models.yaml"
  
  selected_models = {
    "prototype_model" = {
      selector       = "ESMC-300M"
    },
    "performance_model" = {
        selector    = "ESMC-300M"
      instance_type  = "ml.g5.4xlarge"
    }
  }
  // Other variables...
}
```

This tells the module to load the model catalog from your custom models.yaml file instead of the one included by default.

## Final Notes

- Ensure your `models.yaml` file is formatted correctly as YAML.
- Validate the file using a YAML linter before integrating it into your Terraform deployment.
- You may need to keep your model ARNs up-to-date as new versions are published, so that your deployments always reference the correct model package.

With this configuration file, you can flexibly manage the models available for deployment in your environment.