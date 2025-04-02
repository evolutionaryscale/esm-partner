.PHONY: *

help:
	@echo  '---------------------------------------------------------------------------'
	@echo  '   Makefile that provides a convenient interface to run helper scripts'
	@echo  '---------------------------------------------------------------------------'
	@echo  ''
	@echo  "Override 'default' profile with env: 'AWS_PROFILE=<name> make <target>'"
	@echo  ''
	@echo  "'make' targets:"
	@echo  '  help                  - Show this help'
	@echo  '  create-state-bucket   - Create an encrypted, versioned, non-public S3'
	@echo  '                          bucket for Terraform state'
	@echo  '  init                  - Run 'terraform init' using remote state bucket'
	@echo  '  plan                  - Run 'terraform plan' using selected workspace'
	@echo  '  apply                 - Run 'terraform apply' using selected workspace'
	@echo  '  delete-endpoints      - Delete SageMaker endpoints (free instances)'
	@echo  ''
	@echo  'CAREFUL: TARGET ACTIONS THAT CANNOT BE UNDONE!'
	@echo  '  destroy-state-bucket  - !!! Permanently destroy S3 state bucket !!!'
	@echo  '  clean                 - !!! Remove local terraform state files !!!'
	@echo  ''

# Default environment (e.g., dev, staging, prod)
WORKSPACE ?= dev

# AWS profile
AWS_PROFILE ?= default

# AWS region for the bucket (can override this as needed)
AWS_REGION ?= us-east-2

# Generate a random suffix (8 hex characters)
RANDOM_SUFFIX := $(shell openssl rand -hex 4)

# Construct the state bucket name, e.g., esm-partner-dev-364ac8fd
STATE_BUCKET_NAME := esm-partner-$(WORKSPACE)-$(RANDOM_SUFFIX)

# Terraform backend config file
BACKEND_CONFIG ?= backend.config

create-state-bucket-config:
	@sed -e "s/WORKSPACE/$(WORKSPACE)/g" \
	    -e "s/AWS_REGION/$(AWS_REGION)/g" \
		-e "s/STATE_BUCKET_NAME/$(STATE_BUCKET_NAME)/g" templates/backend-template.config > $(BACKEND_CONFIG)

# Create an encrypted, versioned, non-public S3 bucket for Terraform state
create-state-bucket: create-state-bucket-config
	@echo "Creating state bucket: $(STATE_BUCKET_NAME)"
	aws --profile=$(AWS_PROFILE) s3api create-bucket --bucket $(STATE_BUCKET_NAME) --region $(AWS_REGION) --create-bucket-configuration LocationConstraint=$(AWS_REGION)
	@echo "Enabling encryption on bucket: $(STATE_BUCKET_NAME)"
	aws --profile=$(AWS_PROFILE) s3api put-bucket-encryption --bucket $(STATE_BUCKET_NAME) --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
	@echo "Enabling versioning on bucket: $(STATE_BUCKET_NAME)"
	aws --profile=$(AWS_PROFILE) s3api put-bucket-versioning --bucket $(STATE_BUCKET_NAME) --versioning-configuration Status=Enabled
	@echo "Blocking public access on bucket: $(STATE_BUCKET_NAME)"
	aws --profile=$(AWS_PROFILE) s3api put-public-access-block --bucket $(STATE_BUCKET_NAME) --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
	@echo "Bucket $(STATE_BUCKET_NAME) created and configured."
	aws --profile=$(AWS_PROFILE) s3 ls | grep $(STATE_BUCKET_NAME)

# Destroy (delete) the state bucket. CAREFUL! This will permanently delete the bucket.
destroy-state-bucket:
	@if [ "$(WORKSPACE)" != "dev" ]; then \
		echo "Error: destroy-state-bucket can only be run in the 'dev' workspace, not in '$(WORKSPACE)'"; \
		exit 1; \
	fi
	@echo "Destroying state bucket..."
	@# Extract the bucket name from $(BACKEND_CONFIG)
	@BUCKET_NAME=`awk -F\" '/^bucket/ {print $$2}' $(BACKEND_CONFIG) 2>/dev/null`; \
	echo "Using bucket: $$BUCKET_NAME"; \
	aws s3api delete-objects \
		--bucket $$BUCKET_NAME \
		--delete "`aws s3api list-object-versions \
			--bucket "$$BUCKET_NAME" \
			--output=json \
			--query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}'`"; \
	aws s3 rb s3://$$BUCKET_NAME --force && \
	rm -i $(BACKEND_CONFIG)

# Existing targets for startup and Terraform operations

init:
	@echo "Initializing terraform and creating workspace $(WORKSPACE)"
	terraform init -backend-config=backend.config
	AWS_PROFILE=partner-prem-dev terraform workspace new dev 

set-workspace:
	AWS_PROFILE=$(AWS_PROFILE) terraform workspace select $(WORKSPACE)

plan: set-workspace
	env AWS_PROFILE=$(AWS_PROFILE) terraform plan

apply: set-workspace
	@echo "Deploying $(WORKSPACE)"
	env AWS_PROFILE=$(AWS_PROFILE) terraform apply

apply-ci:
	@echo "Deploying $(WORKSPACE)"
	env AWS_PROFILE=$(AWS_PROFILE) terraform init -input=false -no-color
	env AWS_PROFILE=$(AWS_PROFILE) terraform apply -auto-approve

clean:
	@if [ "$(WORKSPACE)" != "dev" ]; then \
		echo "Error: clean can only be run in the 'dev' workspace, not in '$(WORKSPACE)'"; \
		exit 1; \
	fi
	@echo "Removing local terraform state files..."
	rm -Rf .terraform .terraform.lock.hcl terraform.tfstate*

delete-endpoints:
	@for endpoint in `terraform output -json | jq -r '.sagemaker_endpoints.value | to_entries[] | .value.endpoint_name'`; do \
	  echo "Deleting endpoint $$endpoint"; \
	  aws sagemaker delete-endpoint --endpoint-name "$$endpoint" --region $(AWS_REGION); \
	done
