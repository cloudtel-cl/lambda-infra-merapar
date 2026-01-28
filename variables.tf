variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "merapar-demo"
}

# Lambda Configuration Variables
variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_log_retention_days" {
  description = "Lambda CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

# CodePipeline Configuration Variables
variable "github_repository" {
  description = "GitHub repository in format: owner/repo-name"
  type        = string
  default     = "cloudtel-cl/lambda-demo-merapar"
}

variable "github_branch" {
  description = "GitHub branch to trigger pipeline"
  type        = string
  default     = "main"
}

variable "buildspec_path" {
  description = "Path to buildspec file in the repository"
  type        = string
  default     = "buildspec.yml"
}
