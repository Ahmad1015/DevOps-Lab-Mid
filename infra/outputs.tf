# Terraform Outputs

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# EKS Outputs (from module)
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "database_security_group_id" {
  description = "Security group ID for Database"
  value       = aws_security_group.database.id
}

# ECR Outputs
output "ecr_backend_repository_url" {
  description = "ECR repository URL for backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "ECR repository URL for frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

# Helpful Commands
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.backend.repository_url}"
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

# Summary
output "deployment_summary" {
  description = "Deployment summary"
  value = <<-EOT
    
    ========================================
    TERRAFORM DEPLOYMENT COMPLETE!
    ========================================
    
    VPC ID: ${aws_vpc.main.id}
    EKS Cluster: ${module.eks.cluster_name}
    EKS Endpoint: ${module.eks.cluster_endpoint}
    RDS Endpoint: ${aws_db_instance.main.endpoint}
    
    ECR Backend: ${aws_ecr_repository.backend.repository_url}
    ECR Frontend: ${aws_ecr_repository.frontend.repository_url}
    
    Next Steps:
    1. Configure kubectl:
       aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
    
    2. Login to ECR:
       aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.backend.repository_url}
    
    3. Build and push images:
       docker build -t ${aws_ecr_repository.backend.repository_url}:latest ./backend
       docker push ${aws_ecr_repository.backend.repository_url}:latest
    
    4. Deploy to Kubernetes:
       kubectl apply -k k8s/
    
    ========================================
  EOT
}
