# lambda-infra-merapar

Terraform infrastructure for Lambda function, API Gateway, and S3 bucket.

## Architecture

This infrastructure includes:
- **API Gateway**: REST API with GET method to invoke Lambda function
- **Lambda Function**: Serverless function with S3 access (code deployed separately)
- **S3 Bucket**: Private bucket accessible only by Lambda function

## Components

- `api_gateway.tf`: API Gateway REST API configuration with GET method
- `lambda.tf`: Lambda function, IAM roles, and permissions
- `s3.tf`: S3 bucket with security configurations
- `provider.tf`: AWS provider configuration
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `states.tf`: Terraform version and provider requirements

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

4. Deploy Lambda code separately from your application repository

## Outputs

After applying, Terraform will output:
- API Gateway URL
- Lambda function name and ARN
- S3 bucket name and ARN

## Notes

- Lambda function code is deployed separately - this creates the infrastructure only
- S3 bucket is private and only accessible by the Lambda function
- API Gateway uses GET method only to invoke Lambda
