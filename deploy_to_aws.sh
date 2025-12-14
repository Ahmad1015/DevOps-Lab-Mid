#!/bin/bash
set -e

echo "============================================================"
echo " AWS DEPLOYMENT AUTOMATION"
echo "============================================================"

# 1. Provision Infrastructure
echo ">>> STEP 1: Provisioning Infrastructure with Terraform..."
cd infra
terraform init
terraform apply -auto-approve
cd ..

# Get Outputs
echo ">>> Fetching Outputs..."
ECR_BACKEND=$(cd infra && terraform output -raw ecr_backend_repository_url)
ECR_FRONTEND=$(cd infra && terraform output -raw ecr_frontend_repository_url)
CLUSTER_NAME=$(cd infra && terraform output -raw cluster_name)
REGION="us-east-1"

echo "    Cluster: $CLUSTER_NAME"
echo "    Backend ECR: $ECR_BACKEND"
echo "    Frontend ECR: $ECR_FRONTEND"

# 2. Configure kubectl
echo ">>> STEP 2: Configuring kubectl for EKS..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 3. Build & Push Images
echo ">>> STEP 3: Building & Pushing Docker Images..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_BACKEND

# Build Backend
echo "    Building Backend..."
docker build -t $ECR_BACKEND:latest ./backend
echo "    Pushing Backend..."
docker push $ECR_BACKEND:latest

# Build Frontend
echo "    Building Frontend..."
docker build -t $ECR_FRONTEND:latest ./frontend
echo "    Pushing Frontend..."
docker push $ECR_FRONTEND:latest

# 4. Update K8s Manifests (Dynamically replace image names)
echo ">>> STEP 4: Updating Kubernetes Manifests..."
# We use sed to replace the image names in the yaml files temporarily or permanently
# Setup a temp directory for manifests to avoid dirtying source
mkdir -p k8s/deployments/generated
cp k8s/deployments/*.yaml k8s/deployments/generated/

# Replace placeholders or old names with ECR URLs
# Note: This assumes the original files had 'devops-lab-app-backend:latest' or similar. 
# Better pattern: Use a template or generic replacement.
sed -i "s|image: .*backend:latest|image: $ECR_BACKEND:latest|g" k8s/deployments/generated/backend.yaml
sed -i "s|image: .*frontend:latest|image: $ECR_FRONTEND:latest|g" k8s/deployments/generated/frontend.yaml

# 5. Run Ansible
echo ">>> STEP 5: Deploying via Ansible..."
# We point Ansible to the generated manifests folder by passing a var
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/deploy-app.yaml \
    -e "k8s_manifests_path=$(pwd)/k8s" \
    -e "ecr_backend_image=$ECR_BACKEND:latest" \
    -e "ecr_frontend_image=$ECR_FRONTEND:latest"

echo "============================================================"
echo " DEPLOYMENT COMPLETE!"
echo "============================================================"
