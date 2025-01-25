#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
else
    echo "Error: .env file not found"
    exit 1
fi

# check if variables are in .env
required_vars=("AWS_ACCOUNT_ID" "AWS_REGION" "CLUSTER_NAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in .env file"
        exit 1
    fi
done

# Convert sensitive data to base64
REDIS_PASSWORD_BASE64=$(echo -n "$REDIS_PASSWORD" | base64)
BACKEND_HOST_BASE64=$(echo -n "$BACKEND_HOST" | base64)
CORS_ORIGIN_BASE64=$(echo -n "$CORS_ORIGIN" | base64)

# Replace secret placeholders
sed -i "s/\${REDIS_PASSWORD_BASE64}/$REDIS_PASSWORD_BASE64/g" k8s/secrets.yaml
sed -i "s/\${BACKEND_HOST_BASE64}/$BACKEND_HOST_BASE64/g" k8s/secrets.yaml
sed -i "s/\${CORS_ORIGIN_BASE64}/$CORS_ORIGIN_BASE64/g" k8s/secrets.yaml

# Install required tools
echo "Installing required tools..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin

# Create EKS cluster
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --nodes 2 \
  --node-type t3.medium

# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$CLUSTER_NAME \
  --namespace kube-system

# Create ECR repositories
aws ecr create-repository --repository-name url-shortener-frontend || true
aws ecr create-repository --repository-name url-shortener-backend || true

# Build and push Docker images
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push frontend
docker build -t url-shortener-frontend ./frontend
docker tag url-shortener-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/url-shortener-frontend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/url-shortener-frontend:latest

# Build and push backend
docker build -t url-shortener-backend ./backend
docker tag url-shortener-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/url-shortener-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/url-shortener-backend:latest

# Replace variables in k8s manifests
for file in k8s/*.yaml; do
  sed -i "s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g" $file
  sed -i "s/\${REGION}/$AWS_REGION/g" $file
done

# Deploy to Kubernetes
kubectl apply -f k8s/

# Wait for services to be ready
echo "Waiting for services to be ready..."
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s

# Get the ALB URL
echo "Getting ALB URL..."
sleep 30  # Wait for ALB to be provisioned
ALB_URL=$(kubectl get ingress url-shortener-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application is accessible at: http://$ALB_URL"

# Initialize and apply Terraform
cd terraform
terraform init
terraform apply -auto-approve

# Get ECR repository URLs
FRONTEND_ECR=$(terraform output -raw frontend_repository_url)
BACKEND_ECR=$(terraform output -raw backend_repository_url)

# Build and push Docker images
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push frontend
docker build -t url-shortener-frontend ./frontend
docker tag url-shortener-frontend:latest $FRONTEND_ECR:latest
docker push $FRONTEND_ECR:latest

# Build and push backend
docker build -t url-shortener-backend ./backend
docker tag url-shortener-backend:latest $BACKEND_ECR:latest
docker push $BACKEND_ECR:latest

# Apply Kubernetes manifests
kubectl apply -f k8s/ 