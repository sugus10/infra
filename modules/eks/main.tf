# EKS Module
# This module creates the EKS cluster and node groups

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnet_ids
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  # EKS Managed Node Groups (only when auto mode is disabled)
  eks_managed_node_groups = var.enable_auto_mode ? {} : {
    main = {
      name = "main"

      instance_types = var.node_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      # Enable cluster autoscaler
      labels = {
        "cluster-autoscaler/enabled" = "true"
        "cluster-autoscaler/cluster" = var.cluster_name
      }

    }
  }

  # Enable cluster addons (EBS CSI Driver disabled for cost optimization)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    # EBS CSI Driver disabled - not needed for stateless applications
    # aws-ebs-csi-driver = {
    #   most_recent = true
    # }
  }

  # Enable EKS control plane logging
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # CloudWatch Log Group
  create_cloudwatch_log_group = true
  cloudwatch_log_group_retention_in_days = 7  # Cost optimization: 7 days retention

  # Security hardening
  cluster_encryption_config = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # aws-auth configmap is now managed separately in version 20.0+

  tags = var.tags
}

# AWS Auth ConfigMap (managed by EKS module in version 20.0+)
# Note: aws-auth management is now built into the main EKS module
