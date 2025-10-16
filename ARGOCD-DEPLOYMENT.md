# ArgoCD Deployment

## 🚀 One-Click Deployment

All ArgoCD deployment files have been organized in the `argocd-deployment/` folder.

### Quick Start

```bash
cd argocd-deployment
./deploy-argocd.sh
```

## 📁 Folder Structure

```
argocd-deployment/
├── deploy-argocd.sh                    # 🚀 One-click deployment script
├── uninstall-argocd.sh                 # 🗑️  Complete uninstall script
├── argocd-ssl-config.yaml              # 🔒 SSL configuration
├── README.md                           # 📖 Detailed documentation
└── argocd-ssl-troubleshooting-guide.md # 🔧 Troubleshooting guide
```

## ✨ Features

- **One-click deployment** - Single command installs everything
- **SSL certificates** - Automatic Let's Encrypt certificates
- **Prerequisites check** - Validates all requirements
- **Internet-facing LoadBalancer** - Automatically configures AWS ELB
- **Complete uninstall** - Clean removal script
- **Comprehensive documentation** - Detailed guides and troubleshooting

## 🎯 What Gets Deployed

- ArgoCD with all components
- Let's Encrypt SSL certificates
- Traefik ingress routes
- HTTP to HTTPS redirects
- Proper ArgoCD configuration for reverse proxy

## 📋 Prerequisites

- kubectl (Kubernetes CLI)
- helm (Package manager)
- cert-manager (Certificate management)
- traefik (Ingress controller)

## 🔑 Access

After deployment:
- **URL**: https://argocd.seabed2crest.com
- **Username**: admin
- **Password**: Automatically retrieved and displayed

## 📖 Documentation

See `argocd-deployment/README.md` for complete documentation and troubleshooting.