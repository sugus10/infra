# Environment-Specific Configurations

This document describes the environment-specific configurations for the EKS infrastructure. Each environment is optimized for its specific use case while maintaining consistency and reusability.

## 🏗️ **Environment Structure**

```
environments/
├── dev/                    # Development Environment
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
├── staging/                # Staging Environment
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
└── prod/                   # Production Environment
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── outputs.tf
```

## 🌍 **Environment Overview**

### **Development Environment** (`environments/dev/`)
**Purpose**: Local development, testing, and experimentation

**Key Characteristics**:
- **Cost Optimized**: Minimal resources to keep costs low
- **Single AZ**: Uses 2 availability zones instead of 3
- **Small Instances**: t3.small instances
- **Minimal Nodes**: 1-3 nodes (desired: 1)
- **Public Access**: EKS endpoint publicly accessible
- **Single NAT Gateway**: Cost optimization
- **Budget**: $25/month

**Configuration**:
```hcl
# VPC
vpc_cidr = "10.0.0.0/16"
single_nat_gateway = true
availability_zones = 2

# EKS
node_instance_types = ["t3.small"]
node_group_desired_size = 1
node_group_max_size = 3
cluster_endpoint_public_access = true

# Budget
budget_limit = 25
```

### **Staging Environment** (`environments/staging/`)
**Purpose**: Pre-production testing, integration testing, and validation

**Key Characteristics**:
- **Moderate Resources**: Balanced between cost and functionality
- **All AZs**: Uses all 3 availability zones
- **Medium Instances**: t3.medium instances
- **Moderate Nodes**: 2-5 nodes (desired: 2)
- **Public Access**: EKS endpoint publicly accessible for testing
- **Single NAT Gateway**: Cost optimization
- **Budget**: $75/month

**Configuration**:
```hcl
# VPC
vpc_cidr = "10.1.0.0/16"
single_nat_gateway = true
availability_zones = 3

# EKS
node_instance_types = ["t3.medium"]
node_group_desired_size = 2
node_group_max_size = 5
cluster_endpoint_public_access = true

# Budget
budget_limit = 75
```

### **Production Environment** (`environments/prod/`)
**Purpose**: Live production workloads with high availability and security

**Key Characteristics**:
- **High Availability**: Multiple NAT gateways, all AZs
- **Larger Instances**: t3.large and t3.xlarge instances
- **More Nodes**: 3-10 nodes (desired: 3)
- **Private Access**: EKS endpoint privately accessible for security
- **Multiple NAT Gateways**: High availability
- **Enhanced Monitoring**: Multiple budget alerts
- **Budget**: $200/month

**Configuration**:
```hcl
# VPC
vpc_cidr = "10.2.0.0/16"
single_nat_gateway = false
availability_zones = 3

# EKS
node_instance_types = ["t3.large", "t3.xlarge"]
node_group_desired_size = 3
node_group_max_size = 10
cluster_endpoint_public_access = false

# Budget
budget_limit = 200
```

## 🚀 **Deployment Commands**

### **Deploy Development Environment**
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### **Deploy Staging Environment**
```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

### **Deploy Production Environment**
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## 🔧 **Environment Management**

### **Switching Between Environments**
```bash
# Development
cd environments/dev
terraform workspace select dev

# Staging
cd environments/staging
terraform workspace select staging

# Production
cd environments/prod
terraform workspace select prod
```

### **Environment-Specific Variables**
Each environment has its own `terraform.tfvars` file with environment-specific values:

- **Development**: Cost-optimized, minimal resources
- **Staging**: Balanced resources for testing
- **Production**: High availability, security-focused

### **State Management**
Each environment maintains its own Terraform state:
- `dev/terraform.tfstate`
- `staging/terraform.tfstate`
- `prod/terraform.tfstate`

## 📊 **Cost Comparison**

| Environment | Monthly Cost | Instance Types | Nodes | NAT Gateways | Features |
|-------------|--------------|----------------|-------|--------------|----------|
| **Development** | ~$15-25 | t3.small | 1-3 | 1 | Public access, minimal resources |
| **Staging** | ~$50-75 | t3.medium | 2-5 | 1 | Public access, moderate resources |
| **Production** | ~$150-200 | t3.large/xlarge | 3-10 | 3 | Private access, high availability |

## 🔒 **Security Considerations**

### **Development**
- Public EKS endpoint for easy access
- Minimal security restrictions
- Cost-focused configuration

### **Staging**
- Public EKS endpoint for testing
- Moderate security settings
- Testing-focused configuration

### **Production**
- Private EKS endpoint for security
- Enhanced security settings
- High availability configuration

## 📈 **Scaling Strategies**

### **Development**
- **Auto-scaling**: 1-3 nodes
- **Instance Types**: t3.small only
- **Scaling Triggers**: CPU > 80%

### **Staging**
- **Auto-scaling**: 2-5 nodes
- **Instance Types**: t3.medium only
- **Scaling Triggers**: CPU > 80%

### **Production**
- **Auto-scaling**: 3-10 nodes
- **Instance Types**: t3.large, t3.xlarge
- **Scaling Triggers**: CPU > 70%, Memory > 80%

## 🔄 **Environment Promotion**

### **Dev → Staging**
1. Test changes in development
2. Update staging configuration
3. Deploy to staging
4. Run integration tests

### **Staging → Production**
1. Validate in staging
2. Update production configuration
3. Deploy to production
4. Monitor closely

## 📋 **Best Practices**

### **Environment Isolation**
- Separate VPC CIDR blocks
- Different resource naming
- Isolated state files
- Environment-specific tags

### **Cost Management**
- Environment-specific budgets
- Automated cost alerts
- Resource tagging for cost tracking
- Regular cost reviews

### **Security**
- Principle of least privilege
- Environment-specific access controls
- Regular security audits
- Encryption at rest and in transit

### **Monitoring**
- Environment-specific monitoring
- Customized alert thresholds
- Regular health checks
- Performance monitoring

## 🛠️ **Customization**

### **Adding New Environments**
1. Create new directory under `environments/`
2. Copy existing environment as template
3. Modify variables and configuration
4. Update documentation

### **Modifying Existing Environments**
1. Update environment-specific variables
2. Test changes in development first
3. Apply changes to staging
4. Deploy to production after validation

## 📞 **Support**

For questions about environment configurations:
- **Development**: dev-team@example.com
- **Staging**: staging-team@example.com
- **Production**: platform-team@example.com

## 🔗 **Related Documentation**

- [MODULES.md](./MODULES.md) - Module structure and usage
- [README.md](./README.md) - Overall project documentation
- [examples/](./examples/) - Usage examples
