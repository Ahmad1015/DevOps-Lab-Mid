#!/bin/bash
set -e

echo "============================================================"
echo " AWS CLEANUP SCRIPT"
echo "============================================================"

# 1. Delete Kubernetes Resources (Load Balancers cost money!)
echo ">>> STEP 1: Deleting Kubernetes Resources..."
kubectl delete -f k8s/deployments/generated/ --ignore-not-found=true || true
kubectl delete service frontend-service backend-service redis-service mongodb-service -n devops-lab --ignore-not-found=true || true

# 1.5 Force delete ECR Repositories (Terraform can be picky about non-empty repos)
echo ">>> STEP 1.5: Force Deleting ECR Repositories..."
aws ecr delete-repository --repository-name devops-lab-app-backend --force --region us-east-1 || true
aws ecr delete-repository --repository-name devops-lab-app-frontend --force --region us-east-1 || true

# 2. Terraform Destroy
echo ">>> STEP 2: Destroying Infrastructure (This takes time)..."
cd infra
terraform destroy -auto-approve
cd ..

echo "============================================================"
echo " CLEANUP COMPLETE!"
echo "============================================================"
