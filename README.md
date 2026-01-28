# lambda-infra-merapar

Terraform infrastructure for Lambda function, API Gateway, S3 bucket, and CI/CD Pipeline.

## Architecture

This infrastructure includes:
- **API Gateway**: REST API with GET method to invoke Lambda function
- **Lambda Function**: Serverless function with S3 access
- **S3 Bucket**: Private bucket accessible only by Lambda function
- **CodePipeline**: Automated CI/CD pipeline for Lambda deployments
- **CodeBuild**: Build and package Lambda function from source
- **GitHub Integration**: Automatic deployment on code commits

## Components

- `api_gateway.tf`: API Gateway REST API configuration with GET method
- `lambda.tf`: Lambda function, IAM roles, and permissions
- `s3.tf`: S3 bucket with security configurations
- `codepipeline.tf`: CodePipeline, CodeBuild, and CI/CD infrastructure
- `provider.tf`: AWS provider configuration
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `states.tf`: Terraform version and provider requirements
- `examples/buildspec.yml`: Example buildspec for your Lambda code repository

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

## CodePipeline Setup

This infrastructure creates a complete CI/CD pipeline that automatically deploys your Lambda function when you push code to GitHub.

### Pipeline Flow

```
GitHub (lambda-demo-merapar) → CodeBuild (build & package) → Lambda (deploy)
```

### Prerequisites

1. **GitHub Repository**: `cloudtel-cl/lambda-demo-merapar` with your Lambda function code
2. **buildspec.yml**: Copy `examples/buildspec.yml` to the root of your Lambda code repository

### Initial Setup Steps

1. **Apply the Terraform infrastructure**:
   ```bash
   terraform init
   terraform apply
   ```

2. **Activate the GitHub Connection**:
   After applying, Terraform creates a GitHub connection that requires manual activation:

   - Go to AWS Console → Developer Tools → Connections
   - Find the connection named `merapar-demo-github-connection`
   - Click "Update pending connection"
   - Click "Install a new app" and authorize AWS Connector for GitHub
   - Select the `cloudtel-cl` organization
   - Choose to grant access to specific repositories: `lambda-demo-merapar`
   - Complete the authorization

3. **Add buildspec.yml to your Lambda repository**:
   ```bash
   cd /path/to/lambda-demo-merapar
   cp /path/to/lambda-infra-merapar/examples/buildspec.yml .
   git add buildspec.yml
   git commit -m "Add buildspec for CodePipeline"
   git push
   ```

4. **Pipeline will automatically trigger** on the first push after connection activation

### Configuration Variables

You can customize the pipeline by setting these variables in `terraform.tfvars`:

```hcl
github_repository = "cloudtel-cl/lambda-demo-merapar"  # Your Lambda code repo
github_branch     = "main"                             # Branch to monitor
buildspec_path    = "buildspec.yml"                    # Path to buildspec file
```

### How It Works

1. **Commit & Push**: You push code to `lambda-demo-merapar` repository
2. **Source Stage**: CodePipeline detects the change via GitHub connection
3. **Build Stage**: CodeBuild runs buildspec.yml to:
   - Install Python dependencies from requirements.txt
   - Package Lambda function into a zip file
   - Update Lambda function code
4. **Deploy Stage**: Lambda function is automatically updated with new code
5. **Testing**: Access your Lambda via API Gateway URL

## Outputs

After applying, Terraform will output:
- **API Gateway URL**: Test endpoint for your Lambda function
- **Lambda function name and ARN**: For reference and monitoring
- **S3 bucket name**: Private bucket for Lambda data
- **CodePipeline name**: Monitor pipeline status
- **GitHub connection ARN**: For connection activation
- **Pipeline artifacts bucket**: S3 bucket for build artifacts

## Notes

- **GitHub Connection**: Must be manually activated in AWS Console after first apply
- **S3 Bucket**: Private and only accessible by Lambda function
- **API Gateway**: GET method only
- **Automatic Deployment**: Every commit to the configured branch triggers deployment
- **Build Logs**: Available in CloudWatch under `/aws/codebuild/merapar-demo-build`
