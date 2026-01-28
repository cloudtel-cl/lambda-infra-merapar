# CodePipeline Setup with Terraform - Complete Guide

This guide explains how to set up an automated CI/CD pipeline for your Lambda function using Terraform instead of the AWS Console.

## Repository Structure

You'll be working with **two repositories**:

### 1. `lambda-infra-merapar` (Infrastructure Repository)
**Location**: `/mnt/c/Users/pavid/Documents/Projects/lambda-infra-merapar`

This repository contains all the Terraform code to create:
- Lambda function infrastructure
- API Gateway
- S3 buckets
- **CodePipeline and CodeBuild** ← NEW

**Files Added**:
```
lambda-infra-merapar/
├── codepipeline.tf              # CodePipeline, CodeBuild, IAM roles
├── api_gateway.tf               # API Gateway configuration
├── lambda.tf                    # Lambda function
├── s3.tf                        # S3 bucket for Lambda data
├── provider.tf                  # AWS provider
├── variables.tf                 # Configuration variables (updated)
├── outputs.tf                   # Outputs (updated)
├── states.tf                    # Backend configuration
├── README.md                    # Documentation (updated)
├── CODEPIPELINE_SETUP.md        # This guide
└── examples/
    └── buildspec.yml            # Example buildspec for Lambda repo
```

### 2. `lambda-demo-merapar` (Lambda Code Repository)
**Location**: You need to create or clone this repository

This repository contains your Python Lambda function code.

**Required Files**:
```
lambda-demo-merapar/
├── buildspec.yml                # Build instructions for CodeBuild
├── lambda_function.py           # Your Lambda function code
├── requirements.txt             # Python dependencies (optional)
└── README.md                    # Documentation
```

---

## Step-by-Step Setup

### Step 1: Review and Customize Variables

Edit `lambda-infra-merapar/variables.tf` or create a `terraform.tfvars` file:

```hcl
# Optional: Create terraform.tfvars to override defaults
github_repository = "cloudtel-cl/lambda-demo-merapar"
github_branch     = "main"
project_name      = "merapar-demo"
environment       = "demo"
aws_region        = "us-east-1"
```

### Step 2: Deploy Infrastructure with Terraform

```bash
cd /mnt/c/Users/pavid/Documents/Projects/lambda-infra-merapar

# Initialize Terraform (first time only)
terraform init

# Review what will be created
terraform plan

# Apply the infrastructure
terraform apply
```

**What gets created**:
- ✅ Lambda function (placeholder code)
- ✅ API Gateway with GET method
- ✅ S3 bucket (private, for Lambda)
- ✅ S3 bucket (for pipeline artifacts)
- ✅ CodePipeline
- ✅ CodeBuild project
- ✅ IAM roles and policies
- ✅ GitHub CodeStar connection (requires activation)
- ✅ CloudWatch log groups

### Step 3: Activate GitHub Connection

**IMPORTANT**: The GitHub connection is created in a "PENDING" state and requires manual activation.

1. After `terraform apply` completes, note the output:
   ```
   github_connection_arn = "arn:aws:codestar-connections:us-east-1:274967238699:connection/..."
   github_connection_status = "PENDING"
   ```

2. Go to AWS Console:
   - Navigate to: **Developer Tools** → **Settings** → **Connections**
   - Or direct link: https://console.aws.amazon.com/codesuite/settings/connections

3. Find connection named: `merapar-demo-github-connection`

4. Click **"Update pending connection"**

5. Click **"Install a new app"** (or use existing installation)

6. Authorize **AWS Connector for GitHub**:
   - You'll be redirected to GitHub
   - Select organization: `cloudtel-cl`
   - Choose: **"Only select repositories"**
   - Select: `lambda-demo-merapar`
   - Click **"Install"**

7. Back in AWS Console, click **"Connect"**

8. Connection status changes from "PENDING" → "AVAILABLE" ✅

### Step 4: Prepare Lambda Code Repository

If you don't have the `lambda-demo-merapar` repository yet:

```bash
cd /mnt/c/Users/pavid/Documents/Projects

# Clone or create the repository
# Option A: Clone if it exists
git clone https://github.com/cloudtel-cl/lambda-demo-merapar.git

# Option B: Create new repository
mkdir lambda-demo-merapar
cd lambda-demo-merapar
git init
```

### Step 5: Add buildspec.yml to Lambda Repository

Copy the example buildspec:

```bash
cd /mnt/c/Users/pavid/Documents/Projects/lambda-demo-merapar

# Copy the example buildspec
cp /mnt/c/Users/pavid/Documents/Projects/lambda-infra-merapar/examples/buildspec.yml .

# Review and customize if needed
cat buildspec.yml
```

### Step 6: Create Your Lambda Function Code

Create a simple Python Lambda function:

**lambda_function.py**:
```python
import json
import boto3
import os

s3_client = boto3.client('s3')
BUCKET_NAME = os.environ.get('BUCKET_NAME', '')

def lambda_handler(event, context):
    """
    Main Lambda function handler
    """
    try:
        # Example: List objects in S3 bucket
        if BUCKET_NAME:
            response = s3_client.list_objects_v2(Bucket=BUCKET_NAME)
            objects = [obj['Key'] for obj in response.get('Contents', [])]
        else:
            objects = []

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Hello from Lambda via CodePipeline!',
                'bucket': BUCKET_NAME,
                'objects_count': len(objects),
                'objects': objects[:10]  # First 10 objects
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Error processing request',
                'error': str(e)
            })
        }
```

**requirements.txt** (optional, if you need dependencies):
```
boto3>=1.26.0
```

### Step 7: Commit and Push to Trigger Pipeline

```bash
cd /mnt/c/Users/pavid/Documents/Projects/lambda-demo-merapar

# Add all files
git add buildspec.yml lambda_function.py requirements.txt

# Commit
git commit -m "Initial Lambda function with CodePipeline setup"

# Push to GitHub (replace with your repo URL if needed)
git remote add origin https://github.com/cloudtel-cl/lambda-demo-merapar.git
git push -u origin main
```

### Step 8: Monitor Pipeline Execution

1. **AWS Console → CodePipeline**:
   - Go to: https://console.aws.amazon.com/codesuite/codepipeline/pipelines
   - Find pipeline: `merapar-demo-pipeline`
   - Watch the stages: Source → Build → Deploy

2. **Check CodeBuild logs**:
   - CloudWatch Logs: `/aws/codebuild/merapar-demo-build`

3. **Verify Lambda deployment**:
   ```bash
   aws lambda get-function --function-name merapar-demo-function
   ```

### Step 9: Test Your Lambda Function

1. **Via AWS Console**:
   - Go to Lambda console
   - Open `merapar-demo-function`
   - Click "Test" tab
   - Create test event
   - Click "Test"

2. **Via API Gateway**:
   ```bash
   # Get the API URL from Terraform outputs
   terraform output api_gateway_url

   # Test the endpoint
   curl https://fyaor0rvvg.execute-api.us-east-1.amazonaws.com/demo
   ```

---

## How the Pipeline Works

### Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        CodePipeline Flow                         │
└─────────────────────────────────────────────────────────────────┘

1. Developer Commits Code
   ↓
   [GitHub: lambda-demo-merapar]
   ↓
2. CodePipeline Detects Change (via CodeStar Connection)
   ↓
   [Source Stage]
   - Downloads source code
   - Creates source artifact
   ↓
3. CodeBuild Runs buildspec.yml
   ↓
   [Build Stage]
   - Installs Python runtime (3.11)
   - Installs dependencies (pip install -r requirements.txt)
   - Packages Lambda function (zip file)
   - Uploads artifact to S3
   ↓
4. Lambda Function Updated
   ↓
   [Deploy Stage]
   - Updates Lambda function code
   - New version deployed
   ↓
5. Function Ready
   [API Gateway automatically uses new version]
```

### buildspec.yml Phases

```yaml
phases:
  install:        # Install Python runtime
  pre_build:      # Install application dependencies
  build:          # Package Lambda function into zip
  post_build:     # Update Lambda function code
```

---

## Terraform Files Explained

### codepipeline.tf

This file contains all CI/CD infrastructure:

- **S3 Bucket** (`pipeline_artifacts`): Stores build artifacts
- **CodeBuild Project** (`lambda_build`): Builds and packages Lambda function
- **CodePipeline** (`lambda_pipeline`): Orchestrates the CI/CD flow
- **IAM Roles**:
  - `codepipeline_role`: Allows pipeline to access CodeBuild, Lambda, S3
  - `codebuild_role`: Allows CodeBuild to build and deploy
- **GitHub Connection**: Links AWS to GitHub repository

### Key Resources

```hcl
# CodeBuild Project
resource "aws_codebuild_project" "lambda_build" {
  # Builds Lambda function using buildspec.yml
}

# CodePipeline
resource "aws_codepipeline" "lambda_pipeline" {
  stage {
    name = "Source"    # Get code from GitHub
  }
  stage {
    name = "Build"     # Run CodeBuild
  }
  stage {
    name = "Deploy"    # Update Lambda
  }
}

# GitHub Connection (requires manual activation)
resource "aws_codestarconnections_connection" "github" {
  # Creates connection in PENDING state
}
```

---

## Troubleshooting

### Issue: GitHub connection stays PENDING

**Solution**: You must manually activate it in AWS Console (Step 3 above)

### Issue: Pipeline fails at Source stage

**Cause**: GitHub connection not activated or incorrect repository name

**Solution**:
1. Check connection status in AWS Console
2. Verify repository name in variables: `cloudtel-cl/lambda-demo-merapar`

### Issue: Build fails - "buildspec.yml not found"

**Solution**: Ensure `buildspec.yml` is in the root of lambda-demo-merapar repository

### Issue: Deploy fails - "Access Denied"

**Solution**: Check CodeBuild IAM role has `lambda:UpdateFunctionCode` permission

### Issue: Lambda function not updated after deployment

**Solution**:
1. Check CloudWatch logs: `/aws/codebuild/merapar-demo-build`
2. Verify build completed successfully
3. Check Lambda function last modified timestamp

---

## Updating the Infrastructure

### Add More Stages to Pipeline

Edit `codepipeline.tf` and add new stages:

```hcl
stage {
  name = "Test"

  action {
    name     = "RunTests"
    category = "Test"
    # ... configuration
  }
}
```

Then apply:
```bash
terraform apply
```

### Change GitHub Branch

Update `variables.tf` or `terraform.tfvars`:
```hcl
github_branch = "develop"
```

Then apply:
```bash
terraform apply
```

### Add Build Environment Variables

Edit `codepipeline.tf` in the CodeBuild project:

```hcl
environment_variable {
  name  = "MY_VARIABLE"
  value = "my-value"
}
```

---

## Cost Considerations

**What you'll pay for**:
- CodePipeline: $1/month per active pipeline
- CodeBuild: $0.005/build minute (free tier: 100 minutes/month)
- S3: Storage for artifacts (minimal)
- Lambda: Invocations (free tier: 1M requests/month)

**Estimated monthly cost**: < $2 for low-volume usage

---

## Next Steps

1. ✅ Apply Terraform infrastructure
2. ✅ Activate GitHub connection
3. ✅ Add buildspec.yml to Lambda repository
4. ✅ Push code to trigger first deployment
5. ⬜ Set up CloudWatch alarms for monitoring
6. ⬜ Add automated tests to pipeline
7. ⬜ Configure multiple environments (dev, staging, prod)

---

## Summary

### What You Created with Terraform

| Resource | Purpose | Location |
|----------|---------|----------|
| CodePipeline | Orchestrates CI/CD | `codepipeline.tf` |
| CodeBuild | Builds Lambda package | `codepipeline.tf` |
| Lambda Function | Runs your code | `lambda.tf` |
| API Gateway | HTTP endpoint | `api_gateway.tf` |
| S3 Buckets | Data + Artifacts | `s3.tf`, `codepipeline.tf` |
| IAM Roles | Permissions | `codepipeline.tf`, `lambda.tf` |
| GitHub Connection | Source integration | `codepipeline.tf` |

### Advantages of Terraform Approach

✅ **Infrastructure as Code**: Version controlled, repeatable
✅ **Automation**: One command deploys everything
✅ **Consistency**: Same setup across environments
✅ **Documentation**: Code documents the architecture
✅ **No Manual Clicking**: Everything defined in code
✅ **Easy Updates**: Change code, run `terraform apply`

### Comparison: Console vs Terraform

| Aspect | AWS Console | Terraform |
|--------|-------------|-----------|
| Setup Time | 20-30 mins clicking | 5 mins + one command |
| Reproducibility | Manual each time | Automated |
| Documentation | Screenshots/notes | Code itself |
| Version Control | Not possible | Git tracked |
| Updates | Manual changes | Code changes |
| Multiple Envs | Repeat manually | Copy/paste code |

---

## Support

For issues or questions:
- Check CloudWatch Logs for build errors
- Review Terraform outputs for resource ARNs
- Verify IAM permissions in AWS Console
- Check GitHub connection status
