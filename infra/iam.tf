# IAM Roles and Policies for EKS
# Note: The EKS module handles most IAM resources automatically
# These are additional IAM resources for ECR access

# Additional ECR policy for pulling images from ECR
# (The EKS module creates the base node role)
resource "aws_iam_policy" "ecr_access" {
  name        = "${var.project_name}-ecr-access-policy"
  description = "Allows EKS nodes to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ecr-access-policy"
  }
}
