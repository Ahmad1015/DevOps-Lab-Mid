# ============================================================
# DevOps Final Lab - Golden Path Automation
# ============================================================
# Run: .\demo.ps1
#
# This wrapper script calls the Linux/Bash automation scripts
# to deploy to AWS within your WSL environment.
# ============================================================

param(
    [switch]$Cleanup
)

$ErrorActionPreference = "Stop"

function Write-Header($text) { 
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan 
}

# Ensure scripts are executable
bash -c "chmod +x deploy_to_aws.sh cleanup_aws.sh"

if ($Cleanup) {
    Write-Header "STARTING CLEANUP..."
    bash cleanup_aws.sh
} else {
    Write-Header "STARTING DEPLOYMENT TO AWS..."
    bash deploy_to_aws.sh
}
