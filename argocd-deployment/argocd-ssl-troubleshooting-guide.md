# ArgoCD SSL Certificate Troubleshooting Guide

## Problem Overview

ArgoCD was deployed with Let's Encrypt SSL certificate configuration, but the certificate was failing to be issued and the application was not accessible via HTTPS.

## Initial Error Analysis

### Certificate Status
```bash
kubectl get certificate -n argocd
NAME          READY   SECRET       AGE
argocd-cert   False   argocd-tls   87s
```

### Challenge Failure
```bash
kubectl describe challenge -n argocd
Status:
  Presented:   false
  Processing:  false
  Reason:      Error accepting authorization: acme: authorization error for argocd.seabed2crest.com: 400 urn:ietf:params:acme:error:dns: no valid A records found for argocd.seabed2crest.com; no valid AAAA records found for argocd.seabed2crest.com
  State:       invalid
```

## Root Cause Analysis

### Primary Issue: Internal Load Balancer
The main problem was that the Traefik LoadBalancer service was configured as **internal-only** in AWS, making it inaccessible from the internet.

#### DNS Resolution Before Fix
```bash
nslookup argocd.seabed2crest.com
Server:         192.168.1.1
Address:        192.168.1.1#53

Non-authoritative answer:
argocd.seabed2crest.com canonical name = k8s-traefik-traefik-907a886fdb-72bf946cb16fcd95.elb.ap-south-1.amazonaws.com.
Name:   k8s-traefik-traefik-907a886fdb-72bf946cb16fcd95.elb.ap-south-1.amazonaws.com
Address: 10.0.11.189  # ← PRIVATE IP ADDRESS
```

**Problem**: The ELB was resolving to a private IP (`10.0.11.189`), which Let's Encrypt couldn't reach for HTTP-01 challenge validation.

### Secondary Issue: ArgoCD Server Configuration
ArgoCD server was configured in secure mode, causing redirect loops when combined with Traefik TLS termination.

## Solution Implementation

### Step 1: Make LoadBalancer Internet-Facing

#### Check Current Traefik Service
```bash
kubectl get svc --all-namespaces | grep traefik
traefik        traefik                            LoadBalancer   172.20.89.33     k8s-traefik-traefik-907a886fdb-72bf946cb16fcd95.elb.ap-south-1.amazonaws.com   80:30796/TCP,443:31630/TCP   63m
```

#### Add Internet-Facing Annotation
```bash
kubectl patch svc traefik -n traefik -p '{"metadata":{"annotations":{"service.beta.kubernetes.io/aws-load-balancer-scheme":"internet-facing"}}}'
```

**Result**: AWS provisioned a new internet-facing ELB with hostname:
`k8s-traefik-traefik-51a485cd72-126f98ab784898c7.elb.ap-south-1.amazonaws.com`

### Step 2: Update DNS Configuration

Updated DNS CNAME record for `argocd.seabed2crest.com` to point to the new ELB hostname.

#### DNS Resolution After Fix
```bash
nslookup argocd.seabed2crest.com
Server:         192.168.1.1
Address:        192.168.1.1#53

Non-authoritative answer:
argocd.seabed2crest.com canonical name = k8s-traefik-traefik-51a485cd72-126f98ab784898c7.elb.ap-south-1.amazonaws.com.
Name:   k8s-traefik-traefik-51a485cd72-126f98ab784898c7.elb.ap-south-1.amazonaws.com
Address: 43.204.69.56  # ← PUBLIC IP ADDRESS
```

**Result**: Domain now resolves to a public IP address accessible from the internet.

### Step 3: Clean Up and Recreate Certificate

#### Remove Failed Certificate
```bash
kubectl delete certificate argocd-cert -n argocd
kubectl delete secret argocd-tls -n argocd  # (was already deleted)
```

#### Recreate Certificate
```bash
kubectl apply -f argocd-ingressroute.yaml
```

#### Verify Certificate Creation
```bash
kubectl get certificate -n argocd
NAME          READY   SECRET       AGE
argocd-cert   True    argocd-tls   48s  # ← SUCCESS!
```

#### Certificate Details
```bash
kubectl describe certificate argocd-cert -n argocd
Status:
  Conditions:
    Last Transition Time:  2025-10-16T09:20:12Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2026-01-14T08:21:40Z  # Valid until Jan 2026
  Not Before:              2025-10-16T08:21:41Z
  Renewal Time:            2025-12-15T08:21:40Z  # Auto-renewal date
```

### Step 4: Fix ArgoCD Server Configuration

#### Problem: Redirect Loop
Browser showed "ERR_TOO_MANY_REDIRECTS" when accessing `https://argocd.seabed2crest.com`

#### Root Cause
ArgoCD server was configured with `server.insecure: "false"`, causing it to handle HTTPS internally while Traefik was also doing TLS termination.

#### Solution: Enable Insecure Mode
```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
```

#### Restart ArgoCD Server
```bash
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout status deployment argocd-server -n argocd
```

## Final Verification

### HTTPS Connection Test
```bash
curl -I https://argocd.seabed2crest.com
HTTP/2 200 
accept-ranges: bytes
content-security-policy: frame-ancestors 'self';
content-type: text/html; charset=utf-8
date: Thu, 16 Oct 2025 09:24:03 GMT
vary: Accept-Encoding
x-frame-options: sameorigin
x-xss-protection: 1
content-length: 788
```

### API Endpoint Test
```bash
curl -k https://argocd.seabed2crest.com/api/version
{"Version":"v3.1.8+becb020"}
```

## Configuration Files

### ArgoCD IngressRoute Configuration
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-cert
  namespace: argocd
spec:
  secretName: argocd-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - argocd.seabed2crest.com
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
  - match: Host(`argocd.seabed2crest.com`)
    kind: Rule
    services:
    - name: argocd-server
      port: 80
  tls:
    secretName: argocd-tls
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server-http
  namespace: argocd
spec:
  entryPoints:
    - web
  routes:
  - match: Host(`argocd.seabed2crest.com`)
    kind: Rule
    services:
    - name: argocd-server
      port: 80
    middlewares:
    - name: redirect-to-https
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: redirect-to-https
  namespace: argocd
spec:
  redirectScheme:
    scheme: https
    permanent: true
```

### Let's Encrypt ClusterIssuer Configuration
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: sugugalag@gmail.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

## Key Learnings

### 1. AWS LoadBalancer Annotations
- Default EKS LoadBalancer services create **internal** load balancers
- Use `service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing` for public access
- DNS must be updated when ELB hostname changes

### 2. Let's Encrypt HTTP-01 Challenge Requirements
- Domain must resolve to a **public IP address**
- HTTP-01 challenge requires internet accessibility on port 80
- cert-manager creates temporary ingress rules for validation

### 3. ArgoCD Behind Reverse Proxy
- Set `server.insecure: "true"` when using external TLS termination
- Traefik handles TLS, ArgoCD serves HTTP internally
- Prevents redirect loops between proxy and application

### 4. Certificate Management
- Let's Encrypt certificates are valid for 90 days
- cert-manager handles automatic renewal
- Certificates auto-renew at 2/3 of their lifetime (60 days)

## Final Status

✅ **DNS Resolution**: `argocd.seabed2crest.com` → Public IP `43.204.69.56`  
✅ **SSL Certificate**: Valid Let's Encrypt certificate until January 14, 2026  
✅ **Auto-Renewal**: Configured for December 15, 2025  
✅ **HTTP to HTTPS**: Automatic redirect working  
✅ **ArgoCD Access**: Available at `https://argocd.seabed2crest.com`  
✅ **API Endpoint**: Responding correctly  

## Access Information

To get the initial ArgoCD admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Default username: `admin`