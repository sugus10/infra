# Security Module
# This module handles KMS encryption, IAM roles, and security groups

# KMS Key for EKS cluster encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.name}-eks-encryption-key"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.name}-eks-encryption"
  target_key_id = aws_kms_key.eks.key_id
}

# Security Group for EKS Node Groups (only if cluster security group is provided)
resource "aws_security_group" "node_group" {
  count = var.cluster_security_group_id != "" ? 1 : 0
  
  name_prefix = "${var.name}-node-group-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Node to node all ports/protocols"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Node group to cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  egress {
    description = "Node all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-node-group-sg"
  })
}

# Cluster Autoscaler IAM Role (only if OIDC provider is provided)
resource "aws_iam_role" "cluster_autoscaler" {
  count = var.oidc_provider_arn != "" ? 1 : 0
  
  name = "${var.name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
            "${var.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  count = var.oidc_provider_arn != "" ? 1 : 0
  
  name = "${var.name}-cluster-autoscaler"
  role = aws_iam_role.cluster_autoscaler[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}
