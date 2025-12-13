# DevOps Final Lab - Complete Setup Guide

## 📋 Project Overview

This is a production-ready DevOps stack extending the FARM (FastAPI + React + MongoDB) application with:

- **Containerization**: Docker + Docker Compose with Redis cache
- **Orchestration**: Kubernetes (EKS-ready) manifests
- **Infrastructure**: Terraform for AWS (VPC, EKS, ECR, Security Groups)
- **Configuration**: Ansible playbooks for automation
- **CI/CD**: GitHub Actions workflows
- **Monitoring**: Prometheus + Grafana stack

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AWS Cloud (Terraform)                        │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                          VPC (10.0.0.0/16)                      │ │
│  │  ┌──────────────────────┐  ┌──────────────────────────────────┐│ │
│  │  │   Public Subnets     │  │      Private Subnets             ││ │
│  │  │  ┌────────────────┐  │  │  ┌────────────────────────────┐  ││ │
│  │  │  │  NAT Gateway   │  │  │  │        EKS Cluster         │  ││ │
│  │  │  │  Load Balancer │  │  │  │  ┌─────┐ ┌─────┐ ┌─────┐   │  ││ │
│  │  │  └────────────────┘  │  │  │  │Node1│ │Node2│ │Node3│   │  ││ │
│  │  └──────────────────────┘  │  │  └─────┘ └─────┘ └─────┘   │  ││ │
│  │                            │  └────────────────────────────┘  ││ │
│  └────────────────────────────┴──────────────────────────────────┘│ │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster (EKS)                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │
│  │  Frontend   │ │   Backend   │ │   MongoDB   │ │    Redis    │    │
│  │  (React)    │ │  (FastAPI)  │ │ (StatefulSet)│ │   (Cache)   │    │
│  │  2 replicas │ │  2 replicas │ │  1 replica  │ │  1 replica  │    │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘    │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                     Monitoring Namespace                        ││
│  │  ┌─────────────┐                    ┌─────────────┐             ││
│  │  │  Prometheus │ ──── Metrics ────► │   Grafana   │             ││
│  │  │             │                    │  Dashboards │             ││
│  │  └─────────────┘                    └─────────────┘             ││
│  └─────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
DevOps-Lab-Mid/
├── backend/                    # FastAPI backend
│   ├── Dockerfile             # Multi-stage Docker build
│   └── app/                   # Application source
├── frontend/                   # React + Vite frontend
│   ├── Dockerfile             # Production Dockerfile
│   └── Dockerfile.development # Development Dockerfile
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml
│   ├── kustomization.yaml
│   ├── configmaps/
│   ├── secrets/
│   ├── storage/
│   ├── deployments/
│   │   ├── mongodb.yaml
│   │   ├── redis.yaml
│   │   ├── backend.yaml
│   │   └── frontend.yaml
│   ├── ingress.yaml
│   └── monitoring/            # Prometheus + Grafana
│       ├── prometheus/
│       ├── grafana/
│       └── kustomization.yaml
├── infra/                      # Terraform AWS infrastructure
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── vpc.tf
│   ├── security-groups.tf
│   ├── iam.tf
│   ├── eks.tf
│   ├── ecr.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── ansible/                    # Ansible configuration
│   ├── ansible.cfg
│   ├── inventory/
│   │   └── hosts.yaml
│   └── playbooks/
│       ├── configure-nodes.yaml
│       ├── deploy-app.yaml
│       └── setup-monitoring.yaml
├── .github/workflows/          # CI/CD pipelines
│   ├── ci.yml
│   └── cd.yml
├── docker-compose.yml          # Local development
└── .env                        # Environment variables
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- kubectl
- Terraform >= 1.0
- AWS CLI (configured)
- Minikube (for local testing)
- Ansible (optional)

### 1. Local Development (Docker Compose)

```bash
# Clone and navigate to project
cd DevOps-Lab-Mid

# Start all services
docker compose up -d --build

# Verify services
docker compose ps

# Access services
# Frontend: http://localhost:5173
# Backend API: http://localhost:8000/docs
# MongoDB: localhost:27017
# Redis: localhost:6379
```

### 2. Kubernetes Deployment (Minikube)

```powershell
# Start Minikube
minikube start --driver=docker

# Deploy application
kubectl apply -k k8s/

# Check status
kubectl get all -n devops-lab

# Access frontend (creates a tunnel)
minikube service frontend-service -n devops-lab

# Deploy monitoring
kubectl create namespace monitoring
kubectl apply -k k8s/monitoring/

# Access Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

### 3. AWS EKS Deployment (Terraform)

```powershell
# Navigate to infrastructure
cd infra

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS settings

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster

# Deploy application to EKS
kubectl apply -k ../k8s/

# View outputs
terraform output
```

### 4. Ansible Deployment

```bash
cd ansible

# Configure nodes (if using EC2 directly)
ansible-playbook playbooks/configure-nodes.yaml

# Deploy application
ansible-playbook playbooks/deploy-app.yaml

# Setup monitoring
ansible-playbook playbooks/setup-monitoring.yaml
```

## 📊 Monitoring

Access Grafana dashboard:

```bash
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin

Pre-configured dashboards:
- DevOps Lab Dashboard (pods, CPU, memory)
- Kubernetes cluster metrics

## 🔐 Secrets Management

Secrets are stored in `k8s/secrets/app-secrets.yaml` (base64 encoded).

**To update secrets:**
```bash
# Encode new value
echo -n "new-password" | base64

# Update the Secret file and apply
kubectl apply -f k8s/secrets/app-secrets.yaml
```

## 🛠️ CI/CD Pipeline

### CI (Pull Request)
- Build & test backend Docker image
- Build & test frontend Docker image
- Integration test with Docker Compose

### CD (Push to main)
- Build & push images to Docker Hub / ECR
- Deploy to GitHub Pages (frontend)
- (Optional) Deploy to EKS

## 📈 Terraform Outputs

After `terraform apply`:
- VPC ID
- EKS Cluster endpoint
- ECR repository URLs
- kubectl configuration command
- ECR login command

## 🧹 Cleanup

### Minikube
```powershell
minikube delete
```

### AWS EKS
```powershell
# Delete Kubernetes resources
kubectl delete -k k8s/
kubectl delete -k k8s/monitoring/

# Destroy infrastructure
cd infra
terraform destroy
```

### Docker Compose
```bash
docker compose down -v
```

## 📝 Deliverables Checklist

| Requirement | Status | Location |
|-------------|--------|----------|
| Dockerfile (optimized, multistage) | ✅ | `backend/Dockerfile`, `frontend/Dockerfile` |
| Docker Compose | ✅ | `docker-compose.yml` |
| Container networking | ✅ | Docker Compose networks |
| Persistent storage | ✅ | MongoDB & Redis volumes |
| No hardcoded secrets | ✅ | `.env`, K8s Secrets |
| VPC + Subnets | ✅ | `infra/vpc.tf` |
| Security Groups | ✅ | `infra/security-groups.tf` |
| EKS Cluster | ✅ | `infra/eks.tf` |
| ECR Repository | ✅ | `infra/ecr.tf` |
| Ansible Playbooks | ✅ | `ansible/playbooks/` |
| GitHub Actions CI/CD | ✅ | `.github/workflows/` |
| Prometheus | ✅ | `k8s/monitoring/prometheus/` |
| Grafana | ✅ | `k8s/monitoring/grafana/` |

## 🆘 Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n devops-lab
kubectl logs <pod-name> -n devops-lab
```

### Terraform errors
```bash
terraform validate
terraform plan -out=tfplan
```

### EKS connection issues
```bash
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster
kubectl cluster-info
```

## 📄 License

MIT License - DevOps Final Lab Project
