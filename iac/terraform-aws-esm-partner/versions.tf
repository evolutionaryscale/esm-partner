terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.10.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
