#!/bin/bash

# ArgoCD Deployment Script for EKS
# This script deploys ArgoCD with Traefik Ingress and Let's Encrypt certificates

set -e

echo "🚀 Starting ArgoCD deployment on EKS..."

# Variables
NAMESPACE="argocd"
DOMAIN="argocd.seabed2crest.com"
EMAIL="sugugalag@gmail.com"

# Create namespace if it doesn't exist
echo "📦 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install cert-manager if not already installed
echo "🔐 Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

# Wait for cert-manager to be ready
echo "⏳ Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager

# Deploy Let's Encrypt ClusterIssuer
echo "🔑 Deploying Let's Encrypt ClusterIssuer..."
kubectl apply -f letsencrypt-issuer.yaml

# Install ArgoCD using Helm
echo "📥 Installing ArgoCD using Helm..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace $NAMESPACE \
  --values argocd-helm-values.yaml \
  --wait

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n $NAMESPACE

# Deploy IngressRoute and Certificate
echo "🌐 Deploying Traefik IngressRoute and Certificate..."
kubectl apply -f argocd-ingressroute.yaml

# Get ArgoCD admin password
echo "🔐 ArgoCD admin password:"
kubectl get secret argocd-initial-admin-secret -n $NAMESPACE -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "✅ ArgoCD deployment completed!"
echo "🌐 Access ArgoCD at: https://$DOMAIN"
echo "👤 Username: admin"
echo "🔑 Password: (see above)"
echo ""
echo "📋 Useful commands:"
echo "  - Check certificate status: kubectl get certificate -n $NAMESPACE"
echo "  - Check ArgoCD pods: kubectl get pods -n $NAMESPACE"
echo "  - Port forward for local access: kubectl port-forward -n $NAMESPACE svc/argocd-server 8080:443"
