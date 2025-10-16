#!/bin/bash

# ============================================
# ArgoCD Uninstall Script
# ============================================
# This script removes ArgoCD and all related resources

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ARGOCD_NAMESPACE="argocd"

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🗑️  ArgoCD Uninstall Script${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "Namespace: ${YELLOW}${ARGOCD_NAMESPACE}${NC}"
echo ""

# Confirmation prompt
echo -e "${RED}⚠️  WARNING: This will completely remove ArgoCD and all its data!${NC}"
echo -e "${YELLOW}This action cannot be undone.${NC}"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo -e "${YELLOW}❌ Uninstall cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🗑️  Starting ArgoCD uninstall...${NC}"
echo ""

# Step 1: Delete SSL configuration
echo -e "${BLUE}🔒 Step 1: Removing SSL configuration...${NC}"
if kubectl get -f argocd-ssl-config.yaml &> /dev/null; then
    kubectl delete -f argocd-ssl-config.yaml
    echo -e "${GREEN}✅ SSL configuration removed${NC}"
else
    echo -e "${YELLOW}⚠️  SSL configuration not found${NC}"
fi
echo ""

# Step 2: Uninstall ArgoCD Helm release
echo -e "${BLUE}📦 Step 2: Uninstalling ArgoCD Helm release...${NC}"
if helm list -n ${ARGOCD_NAMESPACE} | grep -q argocd; then
    helm uninstall argocd -n ${ARGOCD_NAMESPACE}
    echo -e "${GREEN}✅ ArgoCD Helm release removed${NC}"
else
    echo -e "${YELLOW}⚠️  ArgoCD Helm release not found${NC}"
fi
echo ""

# Step 3: Delete persistent volumes (if any)
echo -e "${BLUE}💾 Step 3: Checking for persistent volumes...${NC}"
PVS=$(kubectl get pv -o jsonpath='{.items[?(@.spec.claimRef.namespace=="'${ARGOCD_NAMESPACE}'")].metadata.name}' 2>/dev/null || echo "")
if [ -n "$PVS" ]; then
    echo -e "${YELLOW}Found persistent volumes: $PVS${NC}"
    echo -e "${YELLOW}Deleting persistent volumes...${NC}"
    for pv in $PVS; do
        kubectl delete pv $pv
    done
    echo -e "${GREEN}✅ Persistent volumes removed${NC}"
else
    echo -e "${GREEN}✅ No persistent volumes found${NC}"
fi
echo ""

# Step 4: Delete namespace
echo -e "${BLUE}📁 Step 4: Deleting ArgoCD namespace...${NC}"
if kubectl get namespace ${ARGOCD_NAMESPACE} &> /dev/null; then
    kubectl delete namespace ${ARGOCD_NAMESPACE}
    echo -e "${GREEN}✅ Namespace ${ARGOCD_NAMESPACE} deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Namespace ${ARGOCD_NAMESPACE} not found${NC}"
fi
echo ""

# Step 5: Clean up ClusterIssuer (optional)
echo -e "${BLUE}🔐 Step 5: ClusterIssuer cleanup...${NC}"
echo -e "${YELLOW}Note: ClusterIssuer 'letsencrypt-prod' is shared and may be used by other applications${NC}"
read -p "Do you want to delete the ClusterIssuer 'letsencrypt-prod'? (y/N): " delete_issuer

if [[ $delete_issuer =~ ^[Yy]$ ]]; then
    if kubectl get clusterissuer letsencrypt-prod &> /dev/null; then
        kubectl delete clusterissuer letsencrypt-prod
        echo -e "${GREEN}✅ ClusterIssuer 'letsencrypt-prod' deleted${NC}"
    else
        echo -e "${YELLOW}⚠️  ClusterIssuer 'letsencrypt-prod' not found${NC}"
    fi
else
    echo -e "${BLUE}ℹ️  ClusterIssuer 'letsencrypt-prod' kept (may be used by other applications)${NC}"
fi
echo ""

# Step 6: Verification
echo -e "${BLUE}🔍 Step 6: Verification...${NC}"
echo -e "${YELLOW}Checking for remaining ArgoCD resources...${NC}"

# Check for any remaining resources
REMAINING_PODS=$(kubectl get pods -n ${ARGOCD_NAMESPACE} 2>/dev/null | wc -l || echo "0")
REMAINING_SECRETS=$(kubectl get secrets -n ${ARGOCD_NAMESPACE} 2>/dev/null | wc -l || echo "0")

if [ "$REMAINING_PODS" -eq "0" ] && [ "$REMAINING_SECRETS" -eq "0" ]; then
    echo -e "${GREEN}✅ No remaining ArgoCD resources found${NC}"
else
    echo -e "${YELLOW}⚠️  Some resources may still be terminating${NC}"
fi
echo ""

# Success message
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}🎉 ArgoCD Uninstall Completed!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}📋 What was removed:${NC}"
echo -e "• ArgoCD Helm release"
echo -e "• SSL certificates and configuration"
echo -e "• ArgoCD namespace and all resources"
echo -e "• Persistent volumes (if any)"
echo ""
echo -e "${BLUE}📋 What was kept:${NC}"
echo -e "• Traefik (still running)"
echo -e "• cert-manager (still running)"
echo -e "• ClusterIssuer (if you chose to keep it)"
echo ""
echo -e "${GREEN}🚀 Uninstall completed successfully!${NC}"