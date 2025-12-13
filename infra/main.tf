# Main Terraform Configuration

# This file orchestrates all the infrastructure components
# Run: terraform init && terraform plan && terraform apply

# Local values for common tagging
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current region
data "aws_region" "current" {}
