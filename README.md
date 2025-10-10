# EKS Infrastructure - Modular & Environment-Specific

This repository contains a modularized, production-ready Amazon EKS (Elastic Kubernetes Service) infrastructure with environment-specific configurations for development, staging, and production.

## 🏗️ **Architecture Overview**

This infrastructure is built using a modular approach with environment-specific configurations:

```
infra/
├── modules/                   # Reusable Terraform modules
│   ├── vpc/                  # VPC and networking
│   ├── security/             # Security components (KMS, IAM)
│   ├── eks/                  # EKS cluster and node groups
│   └── monitoring/           # Monitoring and cost management
├── environments/             # Environment-specific configurations
│   ├── dev/                  # Development environment
│   ├── staging/              # Staging environment
│   └── prod/                 # Production environment
└── deploy.sh                 # Deployment script
```

## ✨ **Key Features**

### **Modular Design**
- **VPC Module**: VPC, subnets, NAT gateways, and networking
- **Security Module**: KMS encryption, IAM roles, and security groups
- **EKS Module**: EKS cluster, node groups, and addons
- **Monitoring Module**: CloudWatch alarms and AWS Budgets

### **Environment-Specific Configurations**
- **Development**: Cost-optimized, minimal resources
- **Staging**: Balanced resources for testing
- **Production**: High availability, security-focused

### **Cost Optimization**
- Single NAT Gateway option for non-production
- Environment-specific instance types and scaling
- Budget monitoring and alerts
- Auto-scaling capabilities

### **Security & Compliance**
- KMS encryption for secrets
- IAM Roles for Service Accounts (IRSA)
- Private EKS endpoints for production
- Comprehensive security groups

## 🚀 **Quick Start**

### **1. Deploy Development Environment**
```bash
# Make deployment script executable
chmod +x deploy.sh

# Deploy development environment
./deploy.sh dev init
./deploy.sh dev plan
./deploy.sh dev apply
```

### **2. Deploy Staging Environment**
```bash
./deploy.sh staging init
./deploy.sh staging plan
./deploy.sh staging apply
```

### **3. Deploy Production Environment**
```bash
./deploy.sh prod init
./deploy.sh prod plan
./deploy.sh prod apply
```

## 📊 **Environment Comparison**

| Environment | Monthly Cost | Instance Types | Nodes | NAT Gateways | Features |
|-------------|--------------|----------------|-------|--------------|----------|
| **Development** | ~$25 | t3.nano (Spot) | 1-2 | 1 | Public access, minimal resources, auto-shutdown |
| **Production** | ~$75 | t3.small/medium | 2-5 | 1 | Private access, balanced resources |

## 🔧 **Configuration**

### **Environment-Specific Variables**

Each environment has its own `terraform.tfvars` file:

**Development** (`environments/dev/terraform.tfvars`):
```hcl
environment = "dev"
vpc_cidr = "10.0.0.0/16"
node_instance_types = ["t3.nano"]
node_group_desired_size = 1
budget_limit = 25
enable_spot_instances = true
auto_shutdown_enabled = true
```

**Production** (`environments/prod/terraform.tfvars`):
```hcl
environment = "prod"
vpc_cidr = "10.2.0.0/16"
node_instance_types = ["t3.small", "t3.medium"]
node_group_desired_size = 2
budget_limit = 75
enable_spot_instances = false
```

## 📚 **Documentation**

- **[MODULES.md](./MODULES.md)** - Detailed module documentation
- **[ENVIRONMENTS.md](./ENVIRONMENTS.md)** - Environment-specific configurations
- **[deploy.sh](./deploy.sh)** - Deployment script usage

## 🛠️ **Deployment Script Usage**

```bash
# Show help
./deploy.sh --help

# Initialize environment
./deploy.sh <environment> init

# Plan changes
./deploy.sh <environment> plan

# Apply changes
./deploy.sh <environment> apply

# Apply with auto-approve
./deploy.sh <environment> apply --auto-approve

# Show outputs
./deploy.sh <environment> output

# Destroy infrastructure
./deploy.sh <environment> destroy --auto-approve
```

## 🔒 **Security Features**

### **Encryption**
- KMS encryption for EKS secrets
- Automatic key rotation
- Encryption in transit and at rest

### **Access Control**
- IAM Roles for Service Accounts (IRSA)
- Configurable RBAC through aws-auth
- Private EKS endpoints for production

### **Network Security**
- Private subnets for worker nodes
- Public subnets for load balancers
- Restrictive security group rules

## 📈 **Monitoring & Cost Management**

### **CloudWatch Monitoring**
- CPU and memory utilization alarms
- EKS control plane logging
- Custom metrics and dashboards

### **Cost Management**
- Environment-specific budgets
- Automated cost alerts
- Resource tagging for cost tracking

## 🚀 **Advanced Usage**

### **Custom Module Usage**
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
  single_nat_gateway = true
  tags = local.tags
}
```

### **Environment Promotion**
1. Test changes in development
2. Deploy to staging for validation
3. Promote to production after testing

## 🔧 **Prerequisites**

- Terraform >= 1.0
- AWS CLI configured
- kubectl installed
- Appropriate AWS permissions

## 🆘 **Troubleshooting**

### **Common Issues**

1. **Permission Denied**: Ensure AWS credentials have EKS permissions
2. **VPC Limits**: Check AWS account VPC limits
3. **Subnet Availability**: Verify subnets are available in specified AZs

### **Useful Commands**

```bash
# Check cluster status
aws eks describe-cluster --name <cluster-name> --region <region>

# Update kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name>

# View cluster logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/<cluster-name>
```

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in development environment
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License. See the LICENSE file for details.

## 📞 **Support**

- **Development**: dev-team@example.com
- **Staging**: staging-team@example.com
- **Production**: platform-team@example.com