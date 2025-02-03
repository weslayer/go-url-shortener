# URL Shortener

A URL shortener service built with Go, React, and Redis. DO NOT DEPLOY TS (THIS)

## Local Development
```docker-compose up --build```

## Infrastructure Deployment

1. Install prerequisites:
   - AWS CLI
   - Terraform
   - kubectl
   - Docker

2. Configure AWS credentials:
   ```bash
   aws configure
   ```

3. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

4. Deploy infrastructure:
   ```bash
   ./deploy.sh
   ```

The infrastructure will be created in your AWS account using Terraform, which provides:
- VPC with public and private subnets
- EKS cluster with managed node groups
- ECR repositories for Docker images
- AWS Load Balancer Controller
- All necessary IAM roles and policies

## Environment Setup

1. Update the `.env` file with your values:
   - AWS_ACCOUNT_ID: Your AWS account ID
   - AWS_REGION: Your AWS region (e.g., us-west-2)
   - REDIS_PASSWORD: A secure password for Redis
   - Other variables as needed

## CI/CD Pipeline

The application uses GitHub Actions for continuous integration and deployment:

### CI Pipeline
- Triggered on push to main and pull requests
- Runs backend tests
- Runs frontend linting and build
- Ensures code quality before deployment

### CD Pipeline
- Triggered on push to main
- Builds and pushes Docker images to ECR
- Deploys updated applications to EKS
- Updates Kubernetes deployments with new image versions

### Required Secrets
Add these secrets to your GitHub repository:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
