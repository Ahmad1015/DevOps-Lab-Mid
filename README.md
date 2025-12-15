# DevOps Application (Final Project)

A production-ready full-stack application (FastAPI + React + MongoDB) fully automated with Terraform, Ansible, Kubernetes, and CI/CD.

##  How to Run

### Option 1: Local Development (Docker Compose)
The easiest way to test the logic locally.
```bash
# 1. Start everything
docker-compose up --build

# 2. Access App
# Frontend: http://localhost:5173
# Backend Docs: http://localhost:8000/docs
```

### Option 2: Full AWS Deployment (The "One-Click" Script)
This leverages Terraform and Ansible to build the entire cloud stack.

**Prerequisites:** `aws-cli`, `terraform`, `ansible`, `kubectl`.

```bash
# 1. Run the deployment script
./deploy_to_aws.sh

# Note: This will:
# - Provision VPC & EKS (Terraform)
# - Build & Push Images (Docker)
# - Deploy App & Monitoring (Ansible)
```

##  Infrastructure Setup & Teardown

### Provisioning details
The `infra/` folder contains the Terraform code. available resources:
*   **VPC**: `10.0.0.0/16` with public/private subnets.
*   **EKS**: Managed Kubernetes Cluster (`t3.small` nodes).
*   **Networking**: NAT Gateways and Internet Gateways.

###  Cleanup (Important!)
To avoid AWS charges, you **MUST** run the cleanup script. It handles dependencies (like Load Balancers) that Terraform often misses.

```bash
# Destroy everything
./cleanup_aws.sh
```

##  Project Structure
*   `ansible/`: Configuration management playbooks.
*   `infra/`: Terraform Infrastructure as Code.
*   `k8s/`: Kubernetes Manifests (Blueprints).
*   `backend/` & `frontend/`: Application Source Code.
*   `.github/workflows/`: CI/CD Pipeline definitions.