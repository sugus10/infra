# ArgoCD One-Click Deployment

This folder contains everything needed to deploy ArgoCD with SSL certificates in one command.

## 📁 Files

- `deploy-argocd.sh` - One-click deployment script
- `argocd-ssl-config.yaml` - SSL configuration for ArgoCD
- `README.md` - This file

## 🚀 Quick Start

### Prerequisites

Make sure you have the following installed and configured:

1. **kubectl** - Kubernetes CLI tool
2. **helm** - Kubernetes package manager
3. **cert-manager** - Certificate management for Kubernetes
4. **traefik** - Ingress controller

### Install Prerequisites (if needed)

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Traefik (example with Helm)
helm repo add traefik https://traefik.github.io/charts
helm install traefik traefik/traefik -n traefik --create-namespace
```

### One-Click Deployment

```bash
cd argocd-deployment
./deploy-argocd.sh
```

That's it! The script will:

1. ✅ Check all prerequisites
2. ✅ Create ArgoCD namespace
3. ✅ Install ArgoCD via Helm
4. ✅ Configure ArgoCD for Traefik
5. ✅ Make Traefik LoadBalancer internet-facing
6. ✅ Deploy SSL configuration
7. ✅ Wait for Let's Encrypt certificate
8. ✅ Provide access credentials

## 🔧 Configuration

### Domain and Email

Edit the script to change these values:

```bash
DOMAIN="argocd.seabed2crest.com"  # Change to your domain
EMAIL="sugugalag@gmail.com"       # Change to your email
```

### Custom Configuration

Edit `argocd-ssl-config.yaml` to modify:
- Domain names
- Email address
- Certificate settings
- Ingress routes

## 📋 What Gets Deployed

### ArgoCD Components
- ArgoCD Server
- ArgoCD Application Controller
- ArgoCD Repository Server
- ArgoCD DEX Server
- ArgoCD Redis
- ArgoCD Notifications Controller

### SSL Components
- Let's Encrypt ClusterIssuer
- SSL Certificate for your domain
- Traefik IngressRoutes (HTTP & HTTPS)
- HTTP to HTTPS redirect middleware

## 🔍 Verification Commands

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check SSL certificate
kubectl get certificate -n argocd

# Check ingress routes
kubectl get ingressroute -n argocd

# Test HTTPS connection
curl -I https://argocd.seabed2crest.com

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🔑 Access Information

After successful deployment:

- **URL**: https://argocd.seabed2crest.com
- **Username**: admin
- **Password**: Retrieved automatically by the script

## 🛠️ Troubleshooting

### Certificate Issues

```bash
# Check certificate status
kubectl describe certificate argocd-cert -n argocd

# Check challenges
kubectl get challenges -n argocd

# Check certificate request
kubectl get certificaterequest -n argocd
```

### ArgoCD Issues

```bash
# Check ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd

# Check ArgoCD server config
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml
```

### Traefik Issues

```bash
# Check Traefik service
kubectl get svc traefik -n traefik

# Check LoadBalancer status
kubectl describe svc traefik -n traefik
```

## 🔄 Cleanup

To remove ArgoCD:

```bash
# Delete ArgoCD
helm uninstall argocd -n argocd

# Delete SSL resources
kubectl delete -f argocd-ssl-config.yaml

# Delete namespace
kubectl delete namespace argocd
```

## 📝 Notes

- The script automatically configures ArgoCD in insecure mode for Traefik
- Traefik LoadBalancer is made internet-facing for Let's Encrypt validation
- SSL certificate auto-renews before expiration
- All resources are deployed in the `argocd` namespace

## 🆘 Support

If you encounter issues:

1. Check the prerequisites are installed
2. Verify your domain DNS is pointing to the LoadBalancer
3. Check the troubleshooting section above
4. Review the deployment logs for specific errors