# DevOps Final Lab - Screenshot Guide

This guide tells you exactly what screenshots to take for your submission.

---

## Screenshot Checklist

### 1. Docker Compose (Step 1)
**Run these commands:**
```powershell
cd DevOps-Lab-Mid
docker compose up -d --build
docker compose ps
```

**Screenshot:** Terminal showing all 4 containers running:
- `mongodb` - healthy
- `redis` - healthy  
- `backend` - running
- `frontend` - running

---

### 2. Terraform Infrastructure (Step 2)

#### 2a. Terraform Apply
**Run:**
```powershell
cd infra
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

**Screenshot:** Terminal showing `terraform apply` completion with:
- Resources created count
- Output showing cluster endpoint, ECR URLs

**Save outputs:**
```powershell
terraform output > terraform-outputs.txt
```

#### 2b. AWS Console Screenshots
Open: https://console.aws.amazon.com

**Take screenshots of:**

1. **VPC Dashboard**
   - Navigate: VPC > Your VPCs
   - Show: `devops-final-lab-vpc`

2. **Subnets**
   - Navigate: VPC > Subnets
   - Show: Public and Private subnets

3. **EKS Cluster**
   - Navigate: EKS > Clusters
   - Show: `devops-lab-cluster` with status ACTIVE

4. **ECR Repositories**
   - Navigate: ECR > Repositories
   - Show: `devops-lab-app-backend` and `devops-lab-app-frontend`

#### 2c. Terraform Destroy Proof
**Run:**
```powershell
terraform destroy
```

**Screenshot:** Terminal showing "Destroy complete! Resources: X destroyed."

---

### 3. Ansible (Step 4)

**Run:**
```powershell
cd ansible
ansible-playbook playbooks/deploy-app.yaml --check
```

**Screenshot:** Terminal showing playbook execution (even if just checking mode).

---

### 4. Kubernetes Deployment (Step 5)

#### 4a. For Minikube (Local)
```powershell
minikube start
kubectl apply -k k8s/
kubectl get pods -n devops-lab
kubectl get svc -n devops-lab
kubectl describe pod backend-xxx -n devops-lab  # replace xxx with actual pod name
```

#### 4b. For EKS (AWS)
```powershell
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster
kubectl apply -k k8s/
kubectl get pods -n devops-lab
kubectl get svc -n devops-lab
kubectl describe pod backend-xxx -n devops-lab
```

**Screenshots needed:**
1. `kubectl get pods -n devops-lab` - showing all pods Running
2. `kubectl get svc -n devops-lab` - showing services with IPs
3. `kubectl describe pod <pod-name>` - showing pod details

---

### 5. CI/CD Pipeline (Step 6)

**Push code to GitHub:**
```bash
git add .
git commit -m "DevOps Final Lab - Complete implementation"
git push origin main
```

**Take screenshots from GitHub Actions:**
1. Navigate: Your Repo > Actions
2. Click on the latest workflow run
3. **Screenshot:** Pipeline with all stages (green checkmarks)

---

### 6. Monitoring (Step 7)

#### Deploy Monitoring Stack
```powershell
kubectl create namespace monitoring
kubectl apply -k k8s/monitoring/
kubectl get pods -n monitoring
```

#### Access Grafana
```powershell
kubectl port-forward svc/grafana -n monitoring 3000:3000
```

Open: http://localhost:3000
- Username: `admin`
- Password: `admin`

**Screenshots needed:**
1. Grafana login screen
2. DevOps Lab Dashboard showing:
   - Running Pods graph
   - CPU Usage
   - Memory Usage

---

## Quick Command Summary

```powershell
# === STEP 1: Docker Compose ===
cd DevOps-Lab-Mid
docker compose up -d --build
docker compose ps
# SCREENSHOT: All containers running

# === STEP 2: Terraform ===
cd infra
terraform init
terraform apply
terraform output > terraform-outputs.txt
# SCREENSHOT: Apply complete + AWS Console
terraform destroy
# SCREENSHOT: Destroy complete

# === STEP 4: Ansible ===
cd ../ansible
ansible-playbook playbooks/deploy-app.yaml --check
# SCREENSHOT: Playbook output

# === STEP 5: Kubernetes ===
minikube start  # or use EKS
kubectl apply -k ../k8s/
kubectl get pods -n devops-lab
kubectl get svc -n devops-lab
kubectl describe pod <pod-name> -n devops-lab
# SCREENSHOT: Pods running, services, pod describe

# === STEP 6: CI/CD ===
# Go to GitHub Actions and screenshot pipeline

# === STEP 7: Monitoring ===
kubectl create namespace monitoring
kubectl apply -k ../k8s/monitoring/
kubectl port-forward svc/grafana -n monitoring 3000:3000
# Open http://localhost:3000 (admin/admin)
# SCREENSHOT: Grafana dashboard

# === CLEANUP ===
.\cleanup.ps1 -All
```

---

## File Attachments for Submission

Include these files:
1. `terraform-outputs.txt` - Terraform output
2. `screenshots/` folder with all screenshots
3. All code files (or GitHub repo link)
4. This README or your lab report
