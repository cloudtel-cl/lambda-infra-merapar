provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "lambda-infra-merapar"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "cloudtel-cl/lambda-infra-merapar"
    }
  }
}
