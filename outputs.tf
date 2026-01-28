# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_stage_name" {
  description = "Stage name of the API Gateway"
  value       = aws_api_gateway_stage.main.stage_name
}

# Lambda Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Lambda"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Lambda"
  value       = aws_s3_bucket.lambda_bucket.arn
}

# Deployment Information
output "deployment_info" {
  description = "Deployment information"
  value = {
    project     = var.project_name
    environment = var.environment
    region      = var.aws_region
  }
}
