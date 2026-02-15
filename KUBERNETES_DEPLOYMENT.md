# GenX FX Kubernetes Deployment Guide

## Overview

This document provides a complete guide for deploying the GenX FX Trading Platform on Kubernetes. The platform consists of multiple microservices running in containers, orchestrated by Kubernetes.

## Architecture

### Services

The platform is composed of the following services:

1. **API Backend** (`api`)
   - FastAPI-based REST API
   - Handles trading logic, AI predictions, and data management
   - Exposed via LoadBalancer on port 8080

2. **Frontend** (`frontend`)
   - React-based web interface
   - Provides user interface for trading and monitoring
   - Exposed via LoadBalancer on port 3000

3. **Trading Bot** (`trading-bot`)
   - Automated trading execution
   - Processes signals and executes trades
   - Internal service (no external exposure)

4. **MySQL Database** (`mysql`)
   - Stores user data, trades, and signals
   - Persistent storage via PVC
   - Internal service on port 3306

5. **Redis Cache** (`redis`)
   - Caching layer for performance
   - Session storage
   - Internal service on port 6379

6. **Grafana Monitoring** (`grafana`)
   - Monitoring and visualization
   - Exposed via LoadBalancer on port 3001

### Network Topology

```
Internet
    |
    v
LoadBalancer (Frontend:3000, API:8080, Grafana:3001)
    |
    v
Kubernetes Cluster (genx-fx namespace)
    |
    +-- Frontend Deployment (2 replicas)
    |
    +-- API Deployment (2 replicas)
    |   |
    |   +-- MySQL Service (ClusterIP)
    |   |   |
    |   |   +-- MySQL Pod + PVC (10Gi)
    |   |
    |   +-- Redis Service (ClusterIP)
    |       |
    |       +-- Redis Pod + PVC (5Gi)
    |
    +-- Trading Bot Deployment (1 replica)
    |   |
    |   +-- Connected to MySQL, Redis, API
    |
    +-- Grafana Deployment (1 replica)
        |
        +-- Grafana Pod + PVC (5Gi)

Shared Storage:
    - Logs PVC (10Gi, ReadWriteMany)
    - Data PVC (20Gi, ReadWriteMany)
```

## Prerequisites

### Required Tools

1. **kubectl** (v1.20+)
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

2. **Docker** (for building images)
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

3. **Kubernetes Cluster**
   - **Local**: Minikube, Kind, Docker Desktop
   - **Cloud**: GKE, EKS, AKS, DigitalOcean Kubernetes

### Kubernetes Cluster Setup

#### Option 1: Minikube (Local Development)

```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start cluster
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable storage-provisioner
```

#### Option 2: Google Kubernetes Engine (GKE)

```bash
# Create cluster
gcloud container clusters create genx-fx-cluster \
    --num-nodes=3 \
    --machine-type=n1-standard-2 \
    --zone=us-central1-a \
    --enable-autoscaling \
    --min-nodes=2 \
    --max-nodes=5

# Get credentials
gcloud container clusters get-credentials genx-fx-cluster --zone=us-central1-a
```

#### Option 3: Amazon EKS

```bash
# Create cluster
eksctl create cluster \
    --name genx-fx-cluster \
    --region us-west-2 \
    --nodegroup-name standard-workers \
    --node-type t3.medium \
    --nodes 3 \
    --nodes-min 2 \
    --nodes-max 5

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name genx-fx-cluster
```

## Deployment Steps

### 1. Build Docker Images

Build and push Docker images to your registry:

```bash
# Build images
docker build -t genxdbx/genxdbxfx1:api-latest -f Dockerfile.api .
docker build -t genxdbx/genxdbxfx1:frontend-latest -f Dockerfile.frontend .
docker build -t genxdbx/genxdbxfx1:trading-latest -f Dockerfile.trading .

# Login to Docker Hub
docker login -u genxdbx

# Push images
docker push genxdbx/genxdbxfx1:api-latest
docker push genxdbx/genxdbxfx1:frontend-latest
docker push genxdbx/genxdbxfx1:trading-latest
```

**Note**: If using GitHub Actions, images will be built automatically on push to main/master branches.

### 2. Configure Secrets

**CRITICAL**: Update secrets before deployment!

Edit `k8s/configs/secrets.yaml`:

```bash
# Generate secure passwords
openssl rand -hex 32  # For SECRET_KEY
openssl rand -hex 32  # For JWT_SECRET
openssl rand -base64 16  # For MYSQL_ROOT_PASSWORD

# Edit secrets file
vi k8s/configs/secrets.yaml
```

Update the following values:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`
- `MT5_PASSWORD`
- `GEMINI_API_KEY`
- `ALPHAVANTAGE_API_KEY`
- `NEWS_API_KEY`
- `NEWSDATA_API_KEY`
- `OPENAI_API_KEY`
- `SECRET_KEY`
- `JWT_SECRET`

### 3. Deploy to Kubernetes

#### Quick Deployment

```bash
cd k8s
./deploy.sh
```

#### Manual Deployment (Step by Step)

```bash
# 1. Create namespace
kubectl apply -f k8s/namespace.yaml

# 2. Create ConfigMaps
kubectl apply -f k8s/configs/configmap.yaml
kubectl apply -f k8s/configs/mysql-init-configmap.yaml

# 3. Create Secrets
kubectl apply -f k8s/configs/secrets.yaml

# 4. Create Persistent Volume Claims
kubectl apply -f k8s/volumes/persistent-volumes.yaml
kubectl wait --for=condition=Bound pvc --all -n genx-fx --timeout=120s

# 5. Deploy MySQL
kubectl apply -f k8s/deployments/mysql-deployment.yaml
kubectl apply -f k8s/services/mysql-service.yaml
kubectl wait --for=condition=ready pod -l app=mysql -n genx-fx --timeout=180s

# 6. Deploy Redis
kubectl apply -f k8s/deployments/redis-deployment.yaml
kubectl apply -f k8s/services/redis-service.yaml
kubectl wait --for=condition=ready pod -l app=redis -n genx-fx --timeout=120s

# 7. Deploy API
kubectl apply -f k8s/deployments/api-deployment.yaml
kubectl apply -f k8s/services/api-service.yaml
kubectl wait --for=condition=ready pod -l app=api -n genx-fx --timeout=180s

# 8. Deploy Frontend
kubectl apply -f k8s/deployments/frontend-deployment.yaml
kubectl apply -f k8s/services/frontend-service.yaml

# 9. Deploy Trading Bot
kubectl apply -f k8s/deployments/trading-bot-deployment.yaml

# 10. Deploy Grafana
kubectl apply -f k8s/deployments/grafana-deployment.yaml
kubectl apply -f k8s/services/grafana-service.yaml
```

#### Using Makefile

```bash
cd k8s

# Validate manifests
make validate

# Deploy
make deploy

# Check status
make status

# View logs
make logs SVC=api

# Port forward
make port-forward
```

### 4. Verify Deployment

```bash
# Check all resources
kubectl get all -n genx-fx

# Check pods
kubectl get pods -n genx-fx -w

# Check services
kubectl get svc -n genx-fx

# Check persistent volumes
kubectl get pvc -n genx-fx

# View events
kubectl get events -n genx-fx --sort-by='.lastTimestamp'
```

### 5. Access Services

#### Cloud Provider (with LoadBalancer)

```bash
# Get external IPs
kubectl get svc -n genx-fx

# Access services at:
# Frontend: http://<FRONTEND-EXTERNAL-IP>:3000
# API: http://<API-EXTERNAL-IP>:8080
# Grafana: http://<GRAFANA-EXTERNAL-IP>:3001
```

#### Local Development (Port Forwarding)

```bash
# Forward all services
kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx &
kubectl port-forward svc/api-service 8080:8080 -n genx-fx &
kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx &

# Access at:
# Frontend: http://localhost:3000
# API: http://localhost:8080
# API Docs: http://localhost:8080/docs
# Grafana: http://localhost:3001 (admin/admin)
```

## Post-Deployment

### 1. Initial Configuration

1. Access Grafana at http://localhost:3001
   - Default credentials: admin/admin
   - Change password on first login
   - Configure data sources

2. Test API endpoints
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8080/docs
   ```

3. Access Frontend
   - Open http://localhost:3000
   - Complete initial setup wizard

### 2. Database Initialization

The database is automatically initialized with:
- User tables
- Trading accounts
- Trading pairs (major Forex pairs + Gold)
- Market data schema
- Trading signals schema

To verify:
```bash
kubectl exec -it deployment/mysql -n genx-fx -- mysql -u root -p genxdb_fx_db
# Enter password from secrets
SHOW TABLES;
```

### 3. Monitoring Setup

1. Configure Grafana dashboards
2. Set up alerts
3. Connect to external monitoring (optional)

## Maintenance

### Scaling

```bash
# Scale API
kubectl scale deployment/api --replicas=3 -n genx-fx

# Scale Frontend
kubectl scale deployment/frontend --replicas=3 -n genx-fx

# Auto-scaling (requires metrics-server)
kubectl autoscale deployment api --cpu-percent=70 --min=2 --max=10 -n genx-fx
```

### Updates

```bash
# Update image
kubectl set image deployment/api api=genxdbx/genxdbxfx1:api-v2.0 -n genx-fx

# Check rollout
kubectl rollout status deployment/api -n genx-fx

# Rollback if needed
kubectl rollout undo deployment/api -n genx-fx

# View rollout history
kubectl rollout history deployment/api -n genx-fx
```

### Backup

```bash
# Backup database
kubectl exec deployment/mysql -n genx-fx -- \
  mysqldump -u root -p<password> genxdb_fx_db > backup.sql

# Backup persistent volumes
kubectl get pvc -n genx-fx -o yaml > pvc-backup.yaml
```

### Logs

```bash
# View logs
kubectl logs -f deployment/api -n genx-fx
kubectl logs -f deployment/frontend -n genx-fx
kubectl logs -f deployment/trading-bot -n genx-fx

# View logs from all pods in deployment
kubectl logs -f deployment/api --all-containers=true -n genx-fx

# Save logs to file
kubectl logs deployment/api -n genx-fx > api-logs.txt
```

## Troubleshooting

### Common Issues

#### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n genx-fx

# Check events
kubectl get events -n genx-fx --sort-by='.lastTimestamp'

# View pod logs
kubectl logs <pod-name> -n genx-fx
```

#### Database Connection Issues

```bash
# Test MySQL connection
kubectl exec -it deployment/api -n genx-fx -- /bin/bash
mysql -h mysql-service -u genx_user -p genxdb_fx_db

# Check MySQL pod
kubectl logs deployment/mysql -n genx-fx

# Verify secrets
kubectl get secret genx-fx-secrets -n genx-fx -o yaml
```

#### Storage Issues

```bash
# Check PVC status
kubectl get pvc -n genx-fx
kubectl describe pvc mysql-pvc -n genx-fx

# Check storage class
kubectl get storageclass

# Check persistent volumes
kubectl get pv
```

#### Image Pull Issues

```bash
# Check if images exist
docker pull genxdbx/genxdbxfx1:api-latest

# Create image pull secret if using private registry
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=genxdbx \
  --docker-password=<password> \
  --docker-email=genxdbxfx1@gmail.com \
  -n genx-fx

# Update deployments to use secret
# Add to spec.imagePullSecrets:
# - name: regcred
```

## Cleanup

### Remove Deployment

```bash
cd k8s
./undeploy.sh
```

Or manually:

```bash
# Delete namespace (removes everything)
kubectl delete namespace genx-fx

# Or delete resources individually
kubectl delete -f k8s/deployments/ -n genx-fx
kubectl delete -f k8s/services/ -n genx-fx
kubectl delete -f k8s/volumes/ -n genx-fx
kubectl delete -f k8s/configs/ -n genx-fx
kubectl delete -f k8s/namespace.yaml
```

## Production Considerations

### Security

1. **Use external secret managers**
   - AWS Secrets Manager
   - Google Secret Manager
   - HashiCorp Vault
   - Sealed Secrets

2. **Enable RBAC**
   - Create service accounts
   - Define roles and role bindings
   - Limit pod permissions

3. **Network Policies**
   - Restrict pod-to-pod communication
   - Allow only necessary traffic

4. **Pod Security**
   - Use security contexts
   - Run as non-root
   - Read-only root filesystem
   - Drop unnecessary capabilities

### High Availability

1. **Multi-node cluster**
2. **Pod disruption budgets**
3. **Multiple replicas for stateless services**
4. **Database replication**
5. **Cross-zone deployment**

### Performance

1. **Resource limits and requests**
2. **Horizontal Pod Autoscaling**
3. **Cluster autoscaling**
4. **CDN for static assets**
5. **Database connection pooling**

### Monitoring & Logging

1. **Prometheus for metrics**
2. **ELK/EFK stack for logs**
3. **Jaeger for tracing**
4. **Alerting with AlertManager**

## Support

For issues or questions:
- GitHub Issues: https://github.com/Mouy-leng/GenX_FX/issues
- Email: admin@genxdbxfx1.com
- Documentation: See k8s/README.md

## License

MIT License - See LICENSE file for details.
