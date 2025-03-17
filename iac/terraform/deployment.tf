##########################################
# Provider & Workspace Setup
##########################################
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    # config in backend.config
  }
}

##########################################
# Variables
##########################################
variable "project_name" {
  description = "Project name for resource naming, e.g., esm-partner"
  type        = string
  default     = "esm-partner"
}

# Note: Terraform workspaces can be used to separate state for different environments
# e.g., terraform workspace new dev, terraform workspace new prod

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets in the new VPC"
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.2.0/24"]
  # default     = ["172.16.0.0/24", "172.16.1.0/24"]
} 

# variable "enable_internet_access" {
#   description = "Whether to provision public networking resources (default false)"
#   type        = bool
#   default     = false
# }

variable "enable_vpc_endpoints" {
  description = "Provision VPC endpoints for S3 and ECR"
  type        = bool
  default     = true
}

# variable "sagemaker_instance_type" {
#   description = "SageMaker endpoint instance type"
#   type        = string
#   default     = "ml.t2.medium"
# }

# variable "model_data_url" {
#   description = "S3 URI for model artifacts (e.g., s3://bucket/path/model.tar.gz)"
#   type        = string
# }

variable "iam_role_name_prefix" {
  description = "Prefix for naming IAM roles"
  type        = string
  default     = "esm"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev",
    Project     = "esm-partner"
  }
}

# ##########################################
# # VPC & Networking
# ##########################################

# Create a new VPC with a parameterized CIDR block.
resource "aws_vpc" "ems-partner" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# Create Private Subnets using the provided CIDR blocks.
data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.ems-partner.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  })
}

# Create a Route Table for the private subnets.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ems-partner.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-rt"
  })
}

# Associate each private subnet with the private route table.
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# # Optionally create public networking resources if enable_internet_access is true.
# resource "aws_internet_gateway" "igw" {
#   count  = var.enable_internet_access ? 1 : 0
#   vpc_id = aws_vpc.main.id

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-${var.environment}-igw"
#   })
# }

# resource "aws_subnet" "public" {
#   count                   = var.enable_internet_access ? length(var.private_subnet_cidrs) : 0
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 100)
#   map_public_ip_on_launch = true
#   availability_zone       = element(data.aws_availability_zones.available.names, count.index)

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
#   })
# }

# resource "aws_route_table" "public" {
#   count  = var.enable_internet_access ? 1 : 0
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw[0].id
#   }

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-${var.environment}-public-rt"
#   })
# }

# resource "aws_route_table_association" "public" {
#   count          = var.enable_internet_access ? length(aws_subnet.public) : 0
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public[0].id
# }

# Collect private subnet IDs and the private route table ID for use with VPC endpoints.
locals {
  private_subnet_ids       = aws_subnet.private[*].id
  private_route_table_ids  = [aws_route_table.private.id]
}

# ##########################################
# # ECR
# ##########################################
# resource "aws_ecr_repository" "esm_partner_ecr" {
#   name                 = "esm-partner-${var.environment}-ecr"
#   image_tag_mutability = "MUTABLE"  # Change to "IMMUTABLE" if you want to prevent retagging.

#   encryption_configuration {
#     encryption_type = "AES256"
#   }

#   tags = var.tags
# }

# TODO: remove
resource "aws_ecr_repository" "esm_partner_ecr" {
  name                 = "esm-partner-${var.environment}"
  image_tag_mutability = "MUTABLE"  # Change to "IMMUTABLE" if you want to prevent retagging.

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

# ##########################################
# # VPC Endpoints (for S3 and ECR)
# ##########################################
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.ems-partner.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "s3" {
  count             = var.enable_vpc_endpoints ? 1 : 0
  vpc_id            = aws_vpc.ems-partner.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.private_route_table_ids

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-s3-endpoint" })
}

resource "aws_vpc_endpoint" "ecr_api" {
  count              = var.enable_vpc_endpoints ? 1 : 0
  vpc_id             = aws_vpc.ems-partner.id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-ecr-api-endpoint" })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count              = var.enable_vpc_endpoints ? 1 : 0
  vpc_id             = aws_vpc.ems-partner.id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-ecr-dkr-endpoint" })
}

##########################################
# IAM for SageMaker
##########################################

data "aws_iam_policy_document" "sagemaker_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "sagemaker.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.iam_role_name_prefix}-sagemaker-exec-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# ##########################################
# # SageMaker Domain
# ##########################################

# resource "aws_sagemaker_domain" "studio" {
#   domain_name             = "esm-partner-${var.environment}"
#   auth_mode               = "IAM"  # or "SSO" if using SSO
#   app_network_access_type = "VpcOnly"

#   vpc_id    = aws_vpc.main.id
#   subnet_id = aws_subnet.private[0].id  # Use one of your private subnets

#   default_user_settings {
#     execution_role = aws_iam_role.sagemaker_execution_role.arn
#     security_groups = [aws_security_group.sagemaker.id]

#     jupyter_server_app_settings {
#       default_resource_spec {
#         instance_type = "ml.t3.medium"
#       }
#     }
#   }

#   tags = var.tags
# }

# resource "aws_sagemaker_domain" "example" {
#   domain_name = "example"
#   auth_mode   = "IAM"
#   vpc_id      = aws_vpc.example.id
#   subnet_ids  = [aws_subnet.example.id]

#   default_user_settings {
#     execution_role = aws_iam_role.example.arn
#   }
# }

# resource "aws_iam_role" "example" {
#   name               = "example"
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.example.json
# }

# data "aws_iam_policy_document" "example" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["sagemaker.amazonaws.com"]
#     }
#   }
# }

# ##########################################
# # SageMaker Resources
# ##########################################

# resource "aws_sagemaker_model" "example" {
#   name               = "${var.environment}-example-sagemaker-model"
#   name = "evolutionaryscale-esm3-small-2024-03"
#   execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

#   primary_container {
#     image         = "763104351884.dkr.ecr.${var.region}.amazonaws.com/tensorflow-inference:2.3.0-cpu"
#     model_data_url = var.model_data_url
#   }

#   tags = var.tags
# }

# resource "aws_sagemaker_endpoint_configuration" "example" {
#   name = "${var.environment}-example-endpoint-config"

#   production_variants {
#     variant_name           = "AllTraffic"
#     model_name             = aws_sagemaker_model.example.name
#     initial_instance_count = 1
#     instance_type          = var.sagemaker_instance_type
#   }

#   tags = var.tags
# }

# resource "aws_sagemaker_endpoint" "example" {
#   name                 = "${var.environment}-example-endpoint"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.example.name

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = var.tags
# }

# ##########################################
# # SageMaker Notebook Instance
# ##########################################

# resource "aws_sagemaker_notebook_instance" "notebook" {
#   name          = "${var.project_name}-${var.environment}-notebook"
#   instance_type = var.notebook_instance_type
#   role_arn      = aws_iam_role.sagemaker_execution_role.arn
#   subnet_id     = element(var.private_subnet_ids, 0)
#   # Optionally, associate a security group (using the same one from VPC endpoints or a dedicated one)
#   security_groups = [aws_security_group.vpc_endpoints.id]

#   tags = var.tags
# }