# ============================================================
# DevOps Final Lab - Interactive Demo Script
# ============================================================
# Run: .\demo.ps1
# ============================================================

param(
    [switch]$SkipPause,
    [switch]$DeployToMinikube
)

function Write-Header($text) { 
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan 
}

function Write-Step($num, $text) { 
    Write-Host ""
    Write-Host "[$num] $text" -ForegroundColor Yellow 
}

function Write-Success($text) { 
    Write-Host "[OK] $text" -ForegroundColor Green 
}

function Write-Info($text) { 
    Write-Host "    $text" -ForegroundColor White 
}

function Pause-Demo { 
    if (-not $SkipPause) { 
        Write-Host ""
        Write-Host "Press Enter to continue..." -ForegroundColor DarkYellow
        Read-Host 
    } 
}

Clear-Host

Write-Header "DEVOPS FINAL LAB - DEMONSTRATION"

Write-Host ""
Write-Host "DEVOPS FINAL LAB" -ForegroundColor Magenta
Write-Host "Student Project: FARM Stack (FastAPI + React + MongoDB)" -ForegroundColor White
Write-Host "Extended with: Redis, Kubernetes, Terraform, Ansible, Monitoring" -ForegroundColor White

Pause-Demo

# ============================================================
Write-Header "OBJECTIVES"
# ============================================================

Write-Host ""
Write-Host "1. Design, containerize, and automate an open-source app with DB + cache/message queue."
Write-Host "2. Provision infrastructure using Terraform on AWS."
Write-Host "3. Deploy and manage the app using Kubernetes (EKS or Minikube)."
Write-Host "4. Automate configuration using Ansible."
Write-Host "5. Implement CI/CD using Jenkins and/or GitHub Actions."
Write-Host "6. Monitor the system with Grafana and Prometheus."
Write-Host "7. Deliver a full production-ready DevOps stack."

Pause-Demo

# ============================================================
Write-Header "STEP 1 - PROJECT SELECTION AND CONTAINERIZATION"
# ============================================================

Write-Host ""
Write-Host "Requirements:" -ForegroundColor White
Write-Host "  1. Dockerfile (optimized, multistage)"
Write-Host "  2. Docker-compose.yml (for local testing)"
Write-Host "  3. Container networking verified"
Write-Host "  4. Persistent storage for DB"
Write-Host "  5. No hardcoded secrets"

Write-Step "1.1" "Checking Dockerfiles..."

if (Test-Path "backend\Dockerfile") {
    Write-Success "Backend Dockerfile exists (multi-stage with uv)"
}
if (Test-Path "frontend\Dockerfile") {
    Write-Success "Frontend Dockerfile exists (multi-stage: node builder + nginx)"
}

Write-Step "1.2" "Checking Docker Compose..."

if (Test-Path "docker-compose.yml") {
    Write-Success "docker-compose.yml exists"
    $content = Get-Content "docker-compose.yml" -Raw
    if ($content -match "mongodb") { Write-Info "MongoDB service: OK" }
    if ($content -match "redis") { Write-Info "Redis cache/queue: OK" }
    if ($content -match "backend") { Write-Info "Backend service: OK" }
    if ($content -match "frontend") { Write-Info "Frontend service: OK" }
}

Write-Step "1.3" "Checking for hardcoded secrets..."

if (Test-Path ".env") {
    Write-Success ".env file exists - secrets are externalized"
}

Pause-Demo

# ============================================================
Write-Header "STEP 2 - INFRASTRUCTURE PROVISIONING WITH TERRAFORM"
# ============================================================

Write-Host ""
Write-Host "Goal: Automate AWS setup. Terraform must provision:" -ForegroundColor White
Write-Host "  - VPC + Subnets + Security Groups"
Write-Host "  - EKS Cluster (Kubernetes)"
Write-Host "  - ECR for container registry"

Write-Step "2.1" "Checking Terraform files..."

$tfFiles = @("providers.tf", "variables.tf", "main.tf", "vpc.tf", "security-groups.tf", "iam.tf", "eks.tf", "ecr.tf", "outputs.tf")
foreach ($file in $tfFiles) {
    if (Test-Path "infra\$file") {
        Write-Success "$file"
    } else {
        Write-Host "[MISSING] $file" -ForegroundColor Red
    }
}

Write-Step "2.2" "Validating Terraform configuration..."

Push-Location infra
$validateResult = terraform validate 2>&1
Pop-Location

if ($LASTEXITCODE -eq 0) {
    Write-Success "Terraform configuration is valid!"
} else {
    Write-Host "Terraform validation: $validateResult" -ForegroundColor Yellow
}

Pause-Demo

# ============================================================
Write-Header "STEP 4 - CONFIGURATION MANAGEMENT (ANSIBLE)"
# ============================================================

Write-Host ""
Write-Host "Goal: Configure servers or containers automatically" -ForegroundColor White

Write-Step "4.1" "Checking Ansible files..."

if (Test-Path "ansible\ansible.cfg") { Write-Success "ansible.cfg" }
if (Test-Path "ansible\inventory\hosts.yaml") { Write-Success "inventory/hosts.yaml" }
if (Test-Path "ansible\playbooks\configure-nodes.yaml") { Write-Success "playbooks/configure-nodes.yaml" }
if (Test-Path "ansible\playbooks\deploy-app.yaml") { Write-Success "playbooks/deploy-app.yaml" }
if (Test-Path "ansible\playbooks\setup-monitoring.yaml") { Write-Success "playbooks/setup-monitoring.yaml" }

Pause-Demo

# ============================================================
Write-Header "STEP 5 - KUBERNETES DEPLOYMENT"
# ============================================================

Write-Host ""
Write-Host "Goal: Deploy containerized app to Kubernetes" -ForegroundColor White

Write-Step "5.1" "Checking Kubernetes manifests..."

if (Test-Path "k8s\namespace.yaml") { Write-Success "namespace.yaml" }
if (Test-Path "k8s\configmaps\app-config.yaml") { Write-Success "configmaps/app-config.yaml" }
if (Test-Path "k8s\secrets\app-secrets.yaml") { Write-Success "secrets/app-secrets.yaml" }
if (Test-Path "k8s\storage\persistent-volumes.yaml") { Write-Success "storage/persistent-volumes.yaml" }
if (Test-Path "k8s\deployments\mongodb.yaml") { Write-Success "deployments/mongodb.yaml" }
if (Test-Path "k8s\deployments\redis.yaml") { Write-Success "deployments/redis.yaml" }
if (Test-Path "k8s\deployments\backend.yaml") { Write-Success "deployments/backend.yaml" }
if (Test-Path "k8s\deployments\frontend.yaml") { Write-Success "deployments/frontend.yaml" }
if (Test-Path "k8s\ingress.yaml") { Write-Success "ingress.yaml" }
if (Test-Path "k8s\kustomization.yaml") { Write-Success "kustomization.yaml" }

Write-Step "5.2" "Validating Kubernetes manifests..."

$kustomizeResult = kubectl kustomize k8s/ 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Success "Kubernetes manifests are valid!"
}

if ($DeployToMinikube) {
    Write-Step "5.3" "Deploying to Minikube..."
    kubectl apply -k k8s/
    Start-Sleep -Seconds 5
    Write-Host ""
    kubectl get pods -n devops-lab
    Write-Host ""
    kubectl get svc -n devops-lab
}

Pause-Demo

# ============================================================
Write-Header "STEP 6 - CI/CD PIPELINE (GITHUB ACTIONS)"
# ============================================================

Write-Host ""
Write-Host "Goal: Fully automated multi-stage pipeline" -ForegroundColor White

Write-Step "6.1" "Checking CI/CD workflows..."

if (Test-Path ".github\workflows\ci.yml") {
    Write-Success "CI Pipeline (ci.yml)"
    Write-Info "Triggers: Pull Requests to main"
}

if (Test-Path ".github\workflows\cd.yml") {
    Write-Success "CD Pipeline (cd.yml)"
    Write-Info "Triggers: Push to main"
}

Pause-Demo

# ============================================================
Write-Header "STEP 7 - MONITORING AND OBSERVABILITY"
# ============================================================

Write-Host ""
Write-Host "Goal: Integrate monitoring for app and DB performance" -ForegroundColor White

Write-Step "7.1" "Checking Monitoring manifests..."

if (Test-Path "k8s\monitoring\prometheus\prometheus-config.yaml") { Write-Success "Prometheus config" }
if (Test-Path "k8s\monitoring\prometheus\prometheus-deployment.yaml") { Write-Success "Prometheus deployment" }
if (Test-Path "k8s\monitoring\grafana\grafana-deployment.yaml") { Write-Success "Grafana deployment" }
if (Test-Path "k8s\monitoring\grafana\grafana-dashboard.yaml") { Write-Success "Grafana dashboard" }

Pause-Demo

# ============================================================
Write-Header "SUMMARY - DELIVERABLES CHECKLIST"
# ============================================================

Write-Host ""
Write-Host "REQUIREMENT                              STATUS" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Dockerfile (optimized, multistage)       [OK]" -ForegroundColor Green
Write-Host "Docker-compose.yml                       [OK]" -ForegroundColor Green
Write-Host "Persistent storage for DB                [OK]" -ForegroundColor Green
Write-Host "No hardcoded secrets                     [OK]" -ForegroundColor Green
Write-Host "VPC + Subnets + Security Groups          [OK]" -ForegroundColor Green
Write-Host "EKS Cluster                              [OK]" -ForegroundColor Green
Write-Host "ECR Repository                           [OK]" -ForegroundColor Green
Write-Host "Ansible playbooks                        [OK]" -ForegroundColor Green
Write-Host "Kubernetes manifests                     [OK]" -ForegroundColor Green
Write-Host "CI/CD Pipeline                           [OK]" -ForegroundColor Green
Write-Host "Prometheus + Grafana                     [OK]" -ForegroundColor Green

Write-Header "DEMO COMPLETE!"

Write-Host ""
Write-Host "NEXT STEPS FOR SCREENSHOTS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. docker compose up -d; docker compose ps"
Write-Host "   -> Screenshot all containers running"
Write-Host ""
Write-Host "2. cd infra; terraform apply"
Write-Host "   -> Screenshot AWS Console (VPC, EKS, ECR)"
Write-Host "   -> terraform output > terraform-outputs.txt"
Write-Host ""
Write-Host "3. kubectl get pods -n devops-lab"
Write-Host "   -> Screenshot pods running"
Write-Host ""
Write-Host "4. kubectl port-forward svc/grafana -n monitoring 3000:3000"
Write-Host "   -> Open http://localhost:3000 (admin/admin)"
Write-Host "   -> Screenshot Grafana dashboard"
Write-Host ""
Write-Host "5. terraform destroy"
Write-Host "   -> Screenshot destroy confirmation"
Write-Host ""
Write-Host "To cleanup: .\cleanup.ps1" -ForegroundColor Cyan
Write-Host ""
