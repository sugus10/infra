# ArgoCD Deployment for EKS

This folder contains all the necessary files to deploy ArgoCD on your EKS cluster with Traefik Ingress and Let's Encrypt SSL certificates.

## 📁 Files Overview

- **`letsencrypt-issuer.yaml`** - Let's Encrypt ClusterIssuer for SSL certificates
- **`argocd-ingressroute.yaml`** - Traefik IngressRoute configuration and Certificate resource
- **`argocd-helm-values.yaml`** - Helm values for ArgoCD deployment
- **`deploy-argocd.sh`** - Automated deployment script
- **`argocd-certificate.yaml`** - Standalone certificate resource (backup)

## 🚀 Quick Deployment

1. **Make the script executable:**
   ```bash
   chmod +x deploy-argocd.sh
   ```

2. **Run the deployment:**
   ```bash
   ./deploy-argocd.sh
   ```

## 🔧 Manual Deployment

If you prefer to deploy manually:

1. **Create namespace:**
   ```bash
   kubectl create namespace argocd
   ```

2. **Install cert-manager:**
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
   ```

3. **Deploy Let's Encrypt issuer:**
   ```bash
   kubectl apply -f letsencrypt-issuer.yaml
   ```

4. **Install ArgoCD:**
   ```bash
   helm repo add argo https://argoproj.github.io/argo-helm
   helm install argocd argo/argo-cd --namespace argocd --values argocd-helm-values.yaml
   ```

5. **Deploy IngressRoute:**
   ```bash
   kubectl apply -f argocd-ingressroute.yaml
   ```

## 🔐 Access Information

- **URL:** https://argocd.seabed2crest.com
- **Username:** admin
- **Password:** Get it with:
  ```bash
  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
  ```

## 🛠️ Troubleshooting

### Certificate Issues
- Check certificate status: `kubectl get certificate -n argocd`
- Check challenges: `kubectl get challenges -n argocd`
- Check certificate details: `kubectl describe certificate argocd-cert -n argocd`

### DNS Issues
- Verify DNS resolution: `nslookup argocd.seabed2crest.com`
- Check if domain points to load balancer: `dig argocd.seabed2crest.com`

### Access Issues
- Port forward for local access: `kubectl port-forward -n argocd svc/argocd-server 8080:443`
- Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-server`

## 📋 Prerequisites

- EKS cluster with Traefik Ingress Controller
- Domain `argocd.seabed2crest.com` pointing to your load balancer
- kubectl configured with cluster access
- Helm installed

## 🔄 Updates

To update ArgoCD:
```bash
helm upgrade argocd argo/argo-cd --namespace argocd --values argocd-helm-values.yaml
```
