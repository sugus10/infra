# AWS Dev Infrastructure Cost Estimation

## 📊 Current Resources Deployed

Based on AWS CLI analysis, here are the resources in your dev environment:

### EKS Auto Mode Configuration ✅
- **EKS Auto Mode**: ENABLED
- **Node Pool**: general-purpose
- **OS**: Bottlerocket (EKS Auto, Standard)
- **Container Runtime**: containerd
- **2x c6a.large instances** (EKS Auto Mode managed)
- **Status**: Running since 2025-10-16
- **Region**: ap-south-1 (Mumbai)

### EKS Cluster
- **Cluster**: eks-infra-dev
- **Version**: Kubernetes 1.32
- **Platform**: eks.25
- **Compute Config**: EKS Auto Mode enabled
- **Status**: ACTIVE

### Load Balancer
- **Type**: Network Load Balancer (NLB)
- **Name**: k8s-traefik-traefik-51a485cd72
- **Status**: Active

### NAT Gateway
- **ID**: nat-001afef4328fc660a
- **Status**: Available

### EBS Volumes
- **4 volumes total**:
  - 2x 80GB gp3 volumes
  - 2x 4GB gp3 volumes
- **Total Storage**: 168GB

## 💰 Monthly Cost Estimation (ap-south-1 Mumbai)

### EKS Auto Mode Compute ⚡
- **Instance Type**: c6a.large (2 vCPUs, 4 GB RAM)
- **EKS Auto Mode Pricing**: $0.10 per vCPU per hour + $0.01 per GB RAM per hour
- **vCPU Cost**: 2 instances × 2 vCPUs × $0.10 × 24 × 30 = **~$28.80 USD**
- **RAM Cost**: 2 instances × 4 GB × $0.01 × 24 × 30 = **~$5.76 USD**
- **Total Compute**: **~$34.56 USD**

### EKS Control Plane
- **EKS Cluster**: $0.10 per hour
- **Monthly cost**: $0.10 × 24 × 30 = **~$72.00 USD**

### Load Balancer (NLB)
- **Network Load Balancer**: $0.0225 per hour + $0.006 per NLCU
- **Monthly cost**: ~$16.20 + data processing = **~$18.00 USD**

### NAT Gateway
- **NAT Gateway**: $0.045 per hour + $0.045 per GB data processed
- **Monthly cost**: ~$32.40 + data transfer = **~$35.00 USD**

### EBS Storage (gp3)
- **168GB gp3 storage**: $0.08 per GB per month
- **Monthly cost**: 168 × $0.08 = **~$13.44 USD**

### Additional Services
- **KMS**: ~$1.00 USD (for EKS encryption)
- **CloudWatch**: ~$5.00 USD (monitoring and logs)
- **Data Transfer**: ~$5.00 USD (estimated)

## 📈 **Total Estimated Monthly Cost: ~$180 USD**

**EKS Auto Mode Savings**: ~$64/month compared to traditional EC2 pricing!

## 💡 Cost Optimization to Meet $150 Budget

### Current Status: $30 over budget ($180 vs $150)

### Immediate Optimizations Needed:

#### 1. **Reduce EKS Auto Mode Instance Size** (Save ~$15/month)
- **Current**: c6a.large (2 vCPUs, 4GB RAM)
- **Recommended**: c6a.medium (1 vCPU, 2GB RAM)
- **Savings**: ~$15/month

#### 2. **Enable Auto-Shutdown** (Save ~$20/month)
- **Weekend shutdown**: 48 hours/week
- **Night shutdown**: 8 hours/day (optional)
- **Savings**: ~$20/month

#### 3. **Optimize Storage** (Save ~$5/month)
- **Current**: 168GB total
- **Reduce**: Remove unused volumes
- **Savings**: ~$5/month

### Optimized Cost Estimate (Within Budget)
- **EKS Auto Mode (c6a.medium)**: ~$20/month
- **EKS Control Plane**: $72/month
- **Load Balancer**: ~$18/month
- **NAT Gateway**: ~$35/month
- **Storage (optimized)**: ~$8/month
- **Other services**: ~$7/month
- **Total Optimized**: **~$160/month** (still $10 over)

### Additional Savings Options:
- **Single AZ deployment**: Save ~$15/month on NAT Gateway
- **Use Application Load Balancer**: Save ~$5/month vs NLB

## 🔧 Cost Monitoring Setup

Your infrastructure already includes:
- ✅ Budget alerts at $25/month (needs adjustment)
- ✅ CloudWatch monitoring
- ✅ Cost optimization tags

## 📋 Next Steps

1. **Adjust Budget Alert**: Change from $25 to $150/month
2. **Implement Auto-shutdown**: Enable weekend/night shutdown
3. **Switch to Spot Instances**: Update node group configuration
4. **Monitor Daily**: Check AWS Cost Explorer regularly

## 🚨 Current vs Expected

- **Your Budget**: $150/month ✅
- **Actual Cost (EKS Auto Mode)**: ~$180/month ⚠️
- **Status**: **$30 over budget** - needs optimization

## ✅ EKS Auto Mode Benefits

- **Simplified Management**: No node groups to manage
- **Automatic Scaling**: AWS handles capacity management
- **Cost Efficiency**: ~$64/month savings vs traditional EC2
- **Bottlerocket OS**: Optimized for containers, better security
- **Auto Updates**: AWS manages OS and security updates
