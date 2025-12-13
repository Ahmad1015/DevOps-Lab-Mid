# ============================================================
# DevOps Final Lab - Cleanup Script
# ============================================================
# Run: .\cleanup.ps1
# ============================================================

param(
    [switch]$All,
    [switch]$Docker,
    [switch]$Kubernetes,
    [switch]$Terraform,
    [switch]$Force
)

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

function Write-Success($text) { 
    Write-Host "  [OK] $text" -ForegroundColor Green 
}

Clear-Host

Write-Header "DEVOPS FINAL LAB - CLEANUP SCRIPT"

Write-Host ""
Write-Host "Options:"
Write-Host "  -Docker      Clean Docker containers and volumes"
Write-Host "  -Kubernetes  Delete Kubernetes resources"
Write-Host "  -Terraform   Destroy AWS infrastructure"
Write-Host "  -All         Clean everything"
Write-Host "  -Force       Skip all confirmations"
Write-Host ""

# If no options specified, show menu
if (-not ($All -or $Docker -or $Kubernetes -or $Terraform)) {
    Write-Host "What would you like to clean up?" -ForegroundColor Cyan
    Write-Host "  1. Docker (containers, images, volumes)"
    Write-Host "  2. Kubernetes (devops-lab and monitoring namespaces)"
    Write-Host "  3. Terraform (AWS infrastructure)"
    Write-Host "  4. All of the above"
    Write-Host "  5. Exit"
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" { $Docker = $true }
        "2" { $Kubernetes = $true }
        "3" { $Terraform = $true }
        "4" { $All = $true }
        "5" { Write-Host "Exiting..." -ForegroundColor Yellow; exit 0 }
        default { Write-Host "Invalid choice. Exiting." -ForegroundColor Red; exit 1 }
    }
}

if ($All) {
    $Docker = $true
    $Kubernetes = $true
    $Terraform = $true
}

# ============================================================
# DOCKER CLEANUP
# ============================================================
if ($Docker) {
    Write-Header "DOCKER CLEANUP"
    
    if (-not $Force) {
        $confirm = Read-Host "Stop and remove Docker containers/volumes? (y/n)"
        if ($confirm -ne "y") {
            Write-Host "Skipping Docker cleanup." -ForegroundColor Yellow
            $Docker = $false
        }
    }
    
    if ($Docker) {
        Write-Step "Stopping Docker Compose services..."
        docker compose down -v 2>$null
        Write-Success "Docker Compose services stopped"
        
        Write-Step "Removing project containers..."
        $containers = @("mongodb", "redis", "backend", "frontend")
        foreach ($container in $containers) {
            docker stop $container 2>$null
            docker rm $container 2>$null
        }
        Write-Success "Project containers removed"
        
        Write-Step "Pruning unused Docker resources..."
        docker system prune -f 2>$null
        Write-Success "Docker resources pruned"
    }
}

# ============================================================
# KUBERNETES CLEANUP
# ============================================================
if ($Kubernetes) {
    Write-Header "KUBERNETES CLEANUP"
    
    if (-not $Force) {
        $confirm = Read-Host "Delete Kubernetes namespaces (devops-lab, monitoring)? (y/n)"
        if ($confirm -ne "y") {
            Write-Host "Skipping Kubernetes cleanup." -ForegroundColor Yellow
            $Kubernetes = $false
        }
    }
    
    if ($Kubernetes) {
        Write-Step "Checking kubectl connectivity..."
        $clusterCheck = kubectl cluster-info 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Step "Deleting application resources..."
            kubectl delete -k k8s/ 2>$null
            Write-Success "Application resources deleted"
            
            Write-Step "Deleting monitoring resources..."
            kubectl delete -k k8s/monitoring/ 2>$null
            Write-Success "Monitoring resources deleted"
            
            Write-Step "Deleting namespaces..."
            kubectl delete namespace devops-lab 2>$null
            kubectl delete namespace monitoring 2>$null
            Write-Success "Namespaces deleted"
        } else {
            Write-Host "  Could not connect to Kubernetes cluster." -ForegroundColor Yellow
            Write-Host "  If using Minikube: minikube delete" -ForegroundColor Yellow
        }
        
        # Check if Minikube is running
        $minikubeStatus = minikube status 2>&1
        if ($LASTEXITCODE -eq 0) {
            $deleteMinikube = Read-Host "Minikube is running. Delete cluster? (y/n)"
            if ($deleteMinikube -eq "y") {
                Write-Step "Deleting Minikube cluster..."
                minikube delete
                Write-Success "Minikube cluster deleted"
            }
        }
    }
}

# ============================================================
# TERRAFORM CLEANUP
# ============================================================
if ($Terraform) {
    Write-Header "TERRAFORM CLEANUP (AWS)"
    
    Write-Host ""
    Write-Host "WARNING: This will DESTROY all AWS resources!" -ForegroundColor Red
    Write-Host "  - VPC and Subnets"
    Write-Host "  - EKS Cluster and Node Groups"
    Write-Host "  - ECR Repositories"
    Write-Host "  - NAT Gateways (charges per hour!)"
    Write-Host ""
    Write-Host "This may take 15-20 minutes to complete." -ForegroundColor Yellow
    Write-Host ""
    
    if (-not $Force) {
        $confirm = Read-Host "Type 'destroy' to confirm AWS cleanup"
        if ($confirm -ne "destroy") {
            Write-Host "Skipping Terraform cleanup." -ForegroundColor Yellow
            $Terraform = $false
        }
    }
    
    if ($Terraform) {
        Write-Step "Navigating to infra directory..."
        
        if (Test-Path "infra") {
            Push-Location infra
            
            Write-Step "Checking Terraform state..."
            $tfState = terraform state list 2>&1
            
            if ($LASTEXITCODE -eq 0 -and $tfState) {
                Write-Host "Found Terraform resources to destroy:" -ForegroundColor DarkGray
                Write-Host $tfState -ForegroundColor DarkGray
                
                Write-Step "Running terraform destroy..."
                Write-Host "  This may take 15-20 minutes..." -ForegroundColor Yellow
                
                terraform destroy -auto-approve
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Terraform resources destroyed!"
                    
                    # Save destroy proof
                    Write-Step "Saving destroy proof..."
                    "Terraform Destroy Completed: $(Get-Date)" | Out-File -FilePath "terraform-destroy-proof.txt"
                    Write-Success "Destroy proof saved to infra/terraform-destroy-proof.txt"
                } else {
                    Write-Host "  Terraform destroy encountered errors." -ForegroundColor Red
                }
            } else {
                Write-Host "  No Terraform resources found to destroy." -ForegroundColor White
                Write-Success "Terraform state is clean"
            }
            
            Pop-Location
        } else {
            Write-Host "  infra/ directory not found" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# SUMMARY
# ============================================================
Write-Header "CLEANUP SUMMARY"

Write-Host ""
Write-Host "Cleanup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Resources cleaned:" -ForegroundColor Green
if ($Docker) { Write-Host "  [OK] Docker containers, images, and volumes" -ForegroundColor Green }
if ($Kubernetes) { Write-Host "  [OK] Kubernetes namespaces and resources" -ForegroundColor Green }
if ($Terraform) { Write-Host "  [OK] AWS infrastructure (Terraform)" -ForegroundColor Green }

Write-Host ""
Write-Host "IMPORTANT: Verify cleanup in AWS Console!" -ForegroundColor Yellow
Write-Host "  1. Open https://console.aws.amazon.com"
Write-Host "  2. Check: EC2, VPC, EKS, ECR"
Write-Host "  3. Manually delete any remaining resources"
Write-Host ""
Write-Host "Screenshot the clean console for your submission." -ForegroundColor Yellow
Write-Host ""
Write-Host "Cleanup script finished." -ForegroundColor Cyan
