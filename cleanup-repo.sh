#!/bin/bash

echo "=========================================="
echo "  GIT REPOSITORY CLEANUP SCRIPT"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will rewrite git history!"
echo "⚠️  Make sure you have a backup!"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

cd /home/mahme/Lab_Final/DevOps-Lab-Mid

echo ""
echo "Step 1: Creating backup..."
cd ..
if [ -d "DevOps-Lab-Mid-backup" ]; then
    rm -rf DevOps-Lab-Mid-backup
fi
cp -r DevOps-Lab-Mid DevOps-Lab-Mid-backup
echo "✅ Backup created at: ../DevOps-Lab-Mid-backup"

cd DevOps-Lab-Mid

echo ""
echo "Step 2: Removing sensitive files from current working directory..."

# Remove sensitive files
rm -f .env
rm -f infra/terraform.tfstate*
rm -f infra/terraform.tfvars
rm -f frontend/.env.production
rm -f frontend/.env.development
rm -f frontend/.env.test
rm -f k8s/secrets/app-secrets.yaml

echo "✅ Sensitive files removed from working directory"

echo ""
echo "Step 3: Creating proper .gitignore..."

cat > .gitignore << 'GITIGNORE_EOF'
# Environment variables
.env
.env.*
*.env
!.env.example

# Terraform
*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
.terraform/
.terraform.lock.hcl

# Kubernetes secrets
k8s/secrets/
k8s/deployments/generated/

# AWS
*.pem
*.key
credentials
config
aws-credentials.txt

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Node
node_modules/
dist/
build/
*.log

# Python
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.venv/
venv/
*.egg-info/

# Docker
.dockerignore

# Logs
*.log
logs/
GITIGNORE_EOF

echo "✅ .gitignore created"

echo ""
echo "Step 4: Creating example files for sensitive data..."

# Create .env.example
cat > .env.example << 'EOF'
# MongoDB Configuration
MONGO_USER=your_mongo_user
MONGO_PASSWORD=your_mongo_password
MONGO_DB=your_database_name
MONGO_PORT=27017

# Backend Configuration
PROJECT_NAME="Your Project Name"
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=your_admin_password
BACKEND_CORS_ORIGINS=["http://localhost:5173","http://localhost:3000"]

# Frontend Configuration
VITE_BACKEND_API_URL=http://localhost:8000/api/v1/
VITE_PWD_SIGNUP_ENABLED=true
VITE_GA_TRACKING_ID=

# Optional: SSO Configuration
# GOOGLE_CLIENT_ID=your_google_client_id
# GOOGLE_CLIENT_SECRET=your_google_client_secret
# SSO_CALLBACK_HOSTNAME=your_hostname
# SSO_LOGIN_CALLBACK_URL=your_callback_url
EOF

# Create terraform.tfvars.example
cat > infra/terraform.tfvars.example << 'EOF'
# Example Terraform Variables - COPY to terraform.tfvars and modify
# DO NOT commit terraform.tfvars to version control

aws_region          = "us-east-1"
environment         = "dev"
project_name        = "your-project"
cluster_name        = "your-cluster"
cluster_version     = "1.29"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# EKS Node Configuration
node_instance_type = "t3.small"
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 3

# ECR Repository
ecr_repository_name = "your-app"

# Database
db_name     = "your_db"
db_username = "your_db_user"
db_password = "CHANGE_THIS_PASSWORD"
EOF

# Create k8s secrets example
mkdir -p k8s/secrets
cat > k8s/secrets/app-secrets.yaml.example << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: devops-lab
type: Opaque
data:
  # All values must be base64 encoded
  # Use: echo -n "value" | base64
  
  MONGO_USER: <base64_encoded_username>
  MONGO_DB: <base64_encoded_db_name>
  MONGO_PASSWORD: <base64_encoded_password>
  
  PROJECT_NAME: <base64_encoded_project_name>
  FIRST_SUPERUSER: <base64_encoded_email>
  FIRST_SUPERUSER_PASSWORD: <base64_encoded_password>
  BACKEND_CORS_ORIGINS: <base64_encoded_json_array>
  
  # Optional SSO
  # GOOGLE_CLIENT_ID: <base64_encoded_client_id>
  # GOOGLE_CLIENT_SECRET: <base64_encoded_client_secret>
  # SSO_CALLBACK_HOSTNAME: <base64_encoded_hostname>
  # SSO_LOGIN_CALLBACK_URL: <base64_encoded_callback_url>
EOF

echo "✅ Example files created"

echo ""
echo "Step 5: Removing sensitive files from git history..."
echo "This may take a few minutes..."

# List of files to remove from history
git-filter-repo --force --invert-paths \
  --path .env \
  --path infra/terraform.tfstate \
  --path infra/terraform.tfstate.backup \
  --path infra/terraform.tfvars \
  --path frontend/.env.production \
  --path frontend/.env.development \
  --path frontend/.env.test \
  --path k8s/secrets/app-secrets.yaml \
  --path infra/terraform-outputs.txt

echo "✅ Git history rewritten"

echo ""
echo "Step 6: Adding safe files to git..."
git add .gitignore
git add .env.example
git add infra/terraform.tfvars.example
git add k8s/secrets/app-secrets.yaml.example
git add -A

echo ""
echo "Step 7: Creating new commit..."
git commit -m "chore: remove sensitive data and add example files

- Removed all environment variables and credentials from history
- Added .env.example and terraform.tfvars.example
- Updated .gitignore for better security
- Cleaned git history using git-filter-repo"

echo ""
echo "=========================================="
echo "  ✅ CLEANUP COMPLETE!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review the changes with: git log --oneline"
echo "2. If everything looks good, force push to GitHub:"
echo "   git push origin main --force"
echo ""
echo "⚠️  IMPORTANT: This will overwrite the remote repository!"
echo "⚠️  Make sure all team members pull the new history."
echo ""
echo "Backup location: ../DevOps-Lab-Mid-backup"
echo "=========================================="
