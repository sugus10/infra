# EKS Infrastructure - Modularized Architecture

This repository contains a modularized EKS infrastructure configuration that is organized into logical, reusable modules.

## 🏗️ **Module Structure**

```
infra/
├── main.tf                    # Main configuration orchestrating all modules
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── terraform.tfvars           # Variable values
├── providers.tf               # Provider configurations
├── versions.tf                # Version constraints
└── modules/                   # Modular components
    ├── vpc/                   # VPC and networking
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security/              # Security components
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/                   # EKS cluster
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── monitoring/            # Monitoring and logging
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## 📦 **Modules Overview**

### **1. VPC Module** (`modules/vpc/`)
**Purpose**: Manages VPC, subnets, NAT gateways, and networking components.

**Key Resources**:
- VPC with configurable CIDR
- Private, public, and intra subnets across 3 AZs
- NAT Gateway (single or multiple for cost optimization)
- Internet Gateway
- Route tables and associations

**Inputs**:
- `name`: Name prefix for resources
- `vpc_cidr`: VPC CIDR block
- `single_nat_gateway`: Use single NAT gateway for cost optimization
- `tags`: Resource tags

**Outputs**:
- VPC ID, CIDR, subnets
- NAT Gateway and Internet Gateway IDs
- Availability zones

### **2. Security Module** (`modules/security/`)
**Purpose**: Handles security components including KMS encryption, IAM roles, and security groups.

**Key Resources**:
- KMS key for EKS secrets encryption
- Security groups for node groups
- IAM role and policy for cluster autoscaler
- KMS key rotation

**Inputs**:
- `name`: Name prefix
- `vpc_id`: VPC ID
- `cluster_security_group_id`: EKS cluster security group ID
- `oidc_provider_arn`: OIDC provider ARN
- `tags`: Resource tags

**Outputs**:
- KMS key ID and ARN
- Security group IDs
- IAM role ARNs

### **3. EKS Module** (`modules/eks/`)
**Purpose**: Creates and manages the EKS cluster and node groups.

**Key Resources**:
- EKS cluster with encryption
- Managed node groups with autoscaler labels
- EKS addons (EBS CSI, CoreDNS, kube-proxy, VPC CNI)
- Control plane logging
- IRSA (IAM Roles for Service Accounts)

**Inputs**:
- `cluster_name`: EKS cluster name
- `kubernetes_version`: K8s version
- `vpc_id`: VPC ID
- `private_subnet_ids`: Private subnet IDs
- `node_instance_types`: Instance types for nodes
- `kms_key_arn`: KMS key for encryption
- `tags`: Resource tags

**Outputs**:
- Cluster ID, ARN, endpoint
- Security group IDs
- OIDC provider details
- CloudWatch log group details

### **4. Monitoring Module** (`modules/monitoring/`)
**Purpose**: Provides monitoring, logging, and cost management.

**Key Resources**:
- CloudWatch alarms for CPU and memory
- AWS Budgets for cost monitoring
- Email notifications for budget alerts

**Inputs**:
- `name`: Name prefix
- `cluster_id`: EKS cluster ID
- `budget_limit`: Monthly budget limit
- `budget_notifications`: Budget alert configurations
- `tags`: Resource tags

**Outputs**:
- Budget name and ARN
- CloudWatch alarm names and ARNs

## 🚀 **Benefits of Modularization**

### **1. Maintainability**
- **Separation of Concerns**: Each module has a single responsibility
- **Easier Debugging**: Issues can be isolated to specific modules
- **Cleaner Code**: Smaller, focused files are easier to understand

### **2. Reusability**
- **Module Reuse**: Modules can be used in different environments
- **Version Control**: Modules can be versioned independently
- **Team Collaboration**: Different teams can work on different modules

### **3. Scalability**
- **Environment Management**: Easy to create dev/staging/prod environments
- **Feature Toggles**: Enable/disable modules based on requirements
- **Incremental Updates**: Update modules independently

### **4. Testing**
- **Unit Testing**: Each module can be tested independently
- **Integration Testing**: Test module interactions
- **Validation**: Validate module configurations separately

## 🔧 **Usage Examples**

### **Basic Usage**
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  name               = "my-cluster"
  vpc_cidr          = "10.0.0.0/16"
  single_nat_gateway = true
  tags              = local.tags
}
```

### **Environment-Specific Configuration**
```hcl
# Development
module "eks" {
  source = "./modules/eks"
  
  cluster_name = "dev-cluster"
  node_instance_types = ["t3.small"]
  node_group_desired_size = 1
}

# Production
module "eks" {
  source = "./modules/eks"
  
  cluster_name = "prod-cluster"
  node_instance_types = ["t3.medium", "t3.large"]
  node_group_desired_size = 3
}
```

## 📋 **Module Dependencies**

```
VPC Module
    ↓
Security Module (depends on VPC)
    ↓
EKS Module (depends on VPC + Security)
    ↓
Monitoring Module (depends on EKS)
```

## 🎯 **Best Practices**

1. **Module Naming**: Use descriptive, consistent naming
2. **Variable Validation**: Add validation rules for critical variables
3. **Output Documentation**: Document all outputs with descriptions
4. **Version Pinning**: Pin module versions for stability
5. **Tagging Strategy**: Consistent tagging across all modules
6. **Error Handling**: Provide clear error messages
7. **Testing**: Test modules independently and together

## 🔄 **Migration from Monolithic**

The original monolithic configuration has been broken down as follows:

- **VPC Configuration** → `modules/vpc/`
- **Security Components** → `modules/security/`
- **EKS Cluster** → `modules/eks/`
- **Monitoring & Budgets** → `modules/monitoring/`

All functionality has been preserved while improving maintainability and reusability.
