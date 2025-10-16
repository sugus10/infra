#!/bin/bash

# ============================================
# ArgoCD One-Click Deployment Script
# ============================================
# This script deploys ArgoCD with SSL certificates in one command
# Prerequisites: kubectl, helm, cert-manager, traefik

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ARGOCD_NAMESPACE="argocd"
DOMAIN="argocd.seabed2crest.com"
EMAIL="sugugalag@gmail.com"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🚀 ArgoCD One-Click Deployment Script${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "Domain: ${YELLOW}${DOMAIN}${NC}"
echo -e "Email: ${YELLOW}${EMAIL}${NC}"
echo -e "Namespace: ${YELLOW}${ARGOCD_NAMESPACE}${NC}"
echo ""

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ Error: $1 is not installed${NC}"
        exit 1
    fi
}

# Function to wait for resource to be ready
wait_for_resource() {
    local resource=$1
    local namespace=$2
    local timeout=${3:-300}
    
    echo -e "${YELLOW}⏳ Waiting for ${resource} to be ready...${NC}"
    kubectl wait --for=condition=ready ${resource} -n ${namespace} --timeout=${timeout}s
}

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
check_command kubectl
check_command helm
echo -e "${GREEN}✅ All prerequisites found${NC}"
echo ""

# Check if cluster is accessible
echo -e "${BLUE}🔗 Checking cluster connectivity...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Error: Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Cluster is accessible${NC}"
echo ""

# Check if cert-manager is installed
echo -e "${BLUE}🔍 Checking cert-manager...${NC}"
if ! kubectl get namespace cert-manager &> /dev/null; then
    echo -e "${RED}❌ Error: cert-manager is not installed${NC}"
    echo -e "${YELLOW}Please install cert-manager first:${NC}"
    echo "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml"
    exit 1
fi
echo -e "${GREEN}✅ cert-manager is installed${NC}"

# Check if traefik is installed
echo -e "${BLUE}🔍 Checking Traefik...${NC}"
if ! kubectl get svc traefik -n traefik &> /dev/null; then
    echo -e "${RED}❌ Error: Traefik is not installed or not in 'traefik' namespace${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Traefik is installed${NC}"
echo ""

# Step 1: Create ArgoCD namespace
echo -e "${BLUE}📁 Step 1: Creating ArgoCD namespace...${NC}"
kubectl create namespace ${ARGOCD_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
echo -e "${GREEN}✅ Namespace ${ARGOCD_NAMESPACE} ready${NC}"
echo ""

# Step 2: Install ArgoCD
echo -e "${BLUE}🎯 Step 2: Installing ArgoCD...${NC}"
if ! helm list -n ${ARGOCD_NAMESPACE} | grep -q argocd; then
    echo -e "${YELLOW}Installing ArgoCD via Helm...${NC}"
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    helm install argocd argo/argo-cd -n ${ARGOCD_NAMESPACE} \
        --set server.service.type=ClusterIP \
        --set server.ingress.enabled=false
    
    echo -e "${YELLOW}⏳ Waiting for ArgoCD pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n ${ARGOCD_NAMESPACE} --timeout=300s
else
    echo -e "${GREEN}✅ ArgoCD is already installed${NC}"
fi
echo ""

# Step 3: Configure ArgoCD for insecure mode (required for Traefik)
echo -e "${BLUE}⚙️  Step 3: Configuring ArgoCD for Traefik...${NC}"
kubectl patch configmap argocd-cmd-params-cm -n ${ARGOCD_NAMESPACE} --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n ${ARGOCD_NAMESPACE}
kubectl rollout status deployment argocd-server -n ${ARGOCD_NAMESPACE}
echo -e "${GREEN}✅ ArgoCD configured for Traefik${NC}"
echo ""

# Step 4: Configure Traefik LoadBalancer as internet-facing
echo -e "${BLUE}🌐 Step 4: Configuring Traefik LoadBalancer...${NC}"
current_scheme=$(kubectl get svc traefik -n traefik -o jsonpath='{.metadata.annotations.service\.beta\.kubernetes\.io/aws-load-balancer-scheme}')
if [ "$current_scheme" != "internet-facing" ]; then
    echo -e "${YELLOW}Making Traefik LoadBalancer internet-facing...${NC}"
    kubectl patch svc traefik -n traefik -p '{"metadata":{"annotations":{"service.beta.kubernetes.io/aws-load-balancer-scheme":"internet-facing"}}}'
    echo -e "${YELLOW}⏳ Waiting for LoadBalancer to be updated...${NC}"
    sleep 30
else
    echo -e "${GREEN}✅ Traefik LoadBalancer is already internet-facing${NC}"
fi
echo ""

# Step 5: Deploy SSL configuration
echo -e "${BLUE}🔒 Step 5: Deploying SSL configuration...${NC}"
kubectl apply -f argocd-ssl-config.yaml
echo -e "${GREEN}✅ SSL configuration applied${NC}"
echo ""

# Step 6: Wait for certificate to be ready
echo -e "${BLUE}📜 Step 6: Waiting for SSL certificate...${NC}"
echo -e "${YELLOW}⏳ This may take a few minutes for Let's Encrypt validation...${NC}"
kubectl wait --for=condition=ready certificate argocd-cert -n ${ARGOCD_NAMESPACE} --timeout=600s
echo -e "${GREEN}✅ SSL certificate is ready${NC}"
echo ""

# Step 7: Get ArgoCD admin password
echo -e "${BLUE}🔑 Step 7: Retrieving ArgoCD admin password...${NC}"
ARGOCD_PASSWORD=$(kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ""

# Final verification
echo -e "${BLUE}🔍 Final verification...${NC}"
echo -e "${YELLOW}Testing HTTPS connection...${NC}"
if curl -s -I https://${DOMAIN} | grep -q "HTTP/2 200"; then
    echo -e "${GREEN}✅ HTTPS connection successful${NC}"
else
    echo -e "${YELLOW}⚠️  HTTPS might still be initializing, please wait a few minutes${NC}"
fi
echo ""

# Success message
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}🎉 ArgoCD Deployment Completed Successfully!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}📋 Access Information:${NC}"
echo -e "URL: ${YELLOW}https://${DOMAIN}${NC}"
echo -e "Username: ${YELLOW}admin${NC}"
echo -e "Password: ${YELLOW}${ARGOCD_PASSWORD}${NC}"
echo ""
echo -e "${BLUE}📋 Useful Commands:${NC}"
echo -e "Check certificate: ${YELLOW}kubectl get certificate -n ${ARGOCD_NAMESPACE}${NC}"
echo -e "Check ArgoCD pods: ${YELLOW}kubectl get pods -n ${ARGOCD_NAMESPACE}${NC}"
echo -e "ArgoCD logs: ${YELLOW}kubectl logs -f deployment/argocd-server -n ${ARGOCD_NAMESPACE}${NC}"
echo ""
echo -e "${GREEN}🚀 ArgoCD is ready to use!${NC}"