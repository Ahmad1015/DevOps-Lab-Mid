# ============================================================
# DevOps Final Lab - Cleanup Script
# ============================================================
# Run: .\cleanup.ps1
# ============================================================

param(
    [switch]$Force
)

$ErrorActionPreference = "SilentlyContinue"

function Write-Header($text) { 
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host $text -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red 
}

function Write-Step($text) { 
    Write-Host ""
    Write-Host "-> $text" -ForegroundColor Yellow 
}

Clear-Host
Write-Header "DEVOPS FINAL LAB - FULL CLEANUP"

if (-not $Force) {
    Write-Host "This will DESTROY:" -ForegroundColor Red
    Write-Host "1. All Kubernetes resources in 'devops-lab'"
    Write-Host "2. All AWS Infrastructure (via Terraform check)"
    Write-Host "3. Local Docker containers and images"
    Write-Host ""
    $confirm = Read-Host "Are you sure? (type 'yes' to proceed)"
    if ($confirm -ne "yes") { exit }
}

# 1. KUBERNETES
Write-Header "1. CLEANING KUBERNETES"
Write-Step "Deleting Namespace devops-lab..."
kubectl delete namespace devops-lab --timeout=60s
Write-Step "Deleting PVCs if remaining..."
kubectl delete pvc --all -n devops-lab

# 2. TERRAFORM
Write-Header "2. CLEANING INFRASTRUCTURE (AWS)"
if (Test-Path "infra") {
    Push-Location infra
    Write-Step "Running terraform destroy..."
    terraform destroy -auto-approve
    Pop-Location
}

# 3. DOCKER
Write-Header "3. CLEANING DOCKER"
Write-Step "Stopping containers..."
docker stop $(docker ps -aq --filter "label=app=backend") 
docker stop $(docker ps -aq --filter "label=app=frontend")
docker stop $(docker ps -aq --filter "label=app=mongodb")
docker stop $(docker ps -aq --filter "label=app=redis")

Write-Step "Removing images..."
docker rmi devops-lab-app-backend:latest
docker rmi devops-lab-app-frontend:latest

Write-Header "CLEANUP COMPLETE"
