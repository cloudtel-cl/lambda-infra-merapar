terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-cloudtel"
    key     = "lambda-infra-merapar/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
