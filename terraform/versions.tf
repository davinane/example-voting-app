terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }


  }
}

provider "aws" {
  region = "ca-central-1"

  default_tags {
    tags = {
      Project     = "TS-Academy-Capstone-1"
      Environment = "learning"
      ManagedBy   = "Terraform"
    }
  }
}
