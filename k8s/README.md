# GenX FX Kubernetes Deployment Guide

This guide provides instructions for deploying the GenX FX Trading Platform on Kubernetes.

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Kubernetes Cluster**: A running Kubernetes cluster (v1.20+)
   - Local: Minikube, Kind, or Docker Desktop
   - Cloud: GKE, EKS, AKS, or DigitalOcean Kubernetes

2. **kubectl**: Kubernetes command-line tool installed and configured
   ```bash
   kubectl version --client
   ```

3. **Docker Images**: Build and push Docker images to a registry
   ```bash
   # Build images
   docker build -t genxdbx/genxdbxfx1:api-latest -f Dockerfile.api .
   docker build -t genxdbx/genxdbxfx1:frontend-latest -f Dockerfile.frontend .
   docker build -t genxdbx/genxdbxfx1:trading-latest -f Dockerfile.trading .
   
   # Push to Docker Hub (or your private registry)
   docker push genxdbx/genxdbxfx1:api-latest
   docker push genxdbx/genxdbxfx1:frontend-latest
   docker push genxdbx/genxdbxfx1:trading-latest
   ```

4. **Storage Class**: Ensure your cluster has a default storage class for persistent volumes
   ```bash
   kubectl get storageclass
   ```

## 🔧 Configuration

### 1. Update Secrets

**IMPORTANT**: Before deploying, update the secrets in `k8s/configs/secrets.yaml`:

```yaml
# Edit the following values:
- MYSQL_ROOT_PASSWORD
- MYSQL_PASSWORD
- MT5_PASSWORD
- GEMINI_API_KEY
- ALPHAVANTAGE_API_KEY
- NEWS_API_KEY
- NEWSDATA_API_KEY
- OPENAI_API_KEY
- SECRET_KEY
- JWT_SECRET
```

Generate secure random secrets:
```bash
# For SECRET_KEY and JWT_SECRET
openssl rand -hex 32
```

### 2. Update ConfigMap (Optional)

If needed, modify `k8s/configs/configmap.yaml` to adjust:
- Database configuration
- Redis configuration
- Application settings
- MT5 server settings

### 3. Adjust Resource Limits

Review and adjust resource requests/limits in deployment files based on your cluster capacity:
- `k8s/deployments/api-deployment.yaml`
- `k8s/deployments/frontend-deployment.yaml`
- `k8s/deployments/trading-bot-deployment.yaml`
- `k8s/deployments/mysql-deployment.yaml`
- `k8s/deployments/redis-deployment.yaml`

## 🚀 Deployment

### Quick Deployment

Run the automated deployment script:

```bash
cd k8s
./deploy.sh
```

The script will:
1. Check prerequisites
2. Create namespace
3. Apply ConfigMaps and Secrets
4. Create Persistent Volume Claims
5. Deploy MySQL database
6. Deploy Redis cache
7. Deploy API backend
8. Deploy frontend
9. Deploy trading bot
10. Deploy Grafana monitoring

### Manual Deployment

If you prefer manual control:

```bash
# 1. Create namespace
kubectl apply -f k8s/namespace.yaml

# 2. Create ConfigMaps
kubectl apply -f k8s/configs/configmap.yaml
kubectl apply -f k8s/configs/mysql-init-configmap.yaml

# 3. Create Secrets (update first!)
kubectl apply -f k8s/configs/secrets.yaml

# 4. Create Persistent Volume Claims
kubectl apply -f k8s/volumes/persistent-volumes.yaml

# 5. Deploy Database and Cache
kubectl apply -f k8s/deployments/mysql-deployment.yaml
kubectl apply -f k8s/services/mysql-service.yaml
kubectl apply -f k8s/deployments/redis-deployment.yaml
kubectl apply -f k8s/services/redis-service.yaml

# Wait for databases to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n genx-fx --timeout=180s
kubectl wait --for=condition=ready pod -l app=redis -n genx-fx --timeout=120s

# 6. Deploy Application Services
kubectl apply -f k8s/deployments/api-deployment.yaml
kubectl apply -f k8s/services/api-service.yaml
kubectl apply -f k8s/deployments/frontend-deployment.yaml
kubectl apply -f k8s/services/frontend-service.yaml
kubectl apply -f k8s/deployments/trading-bot-deployment.yaml

# 7. Deploy Monitoring
kubectl apply -f k8s/deployments/grafana-deployment.yaml
kubectl apply -f k8s/services/grafana-service.yaml
```

## 📊 Monitoring Deployment

### Check Pod Status

```bash
# Watch pods starting up
kubectl get pods -n genx-fx -w

# Get all resources
kubectl get all -n genx-fx

# Describe a pod for troubleshooting
kubectl describe pod <pod-name> -n genx-fx
```

### View Logs

```bash
# API logs
kubectl logs -f deployment/api -n genx-fx

# Frontend logs
kubectl logs -f deployment/frontend -n genx-fx

# Trading bot logs
kubectl logs -f deployment/trading-bot -n genx-fx

# MySQL logs
kubectl logs -f deployment/mysql -n genx-fx
```

### Check Services

```bash
# List services and their external IPs
kubectl get services -n genx-fx

# Get LoadBalancer external IP (if using cloud provider)
kubectl get svc api-service -n genx-fx
kubectl get svc frontend-service -n genx-fx
kubectl get svc grafana-service -n genx-fx
```

## 🌐 Accessing Services

### Using LoadBalancer (Cloud)

If deployed on a cloud provider with LoadBalancer support:

```bash
# Get external IPs
kubectl get svc -n genx-fx

# Access services:
# - Frontend: http://<FRONTEND-EXTERNAL-IP>:3000
# - API: http://<API-EXTERNAL-IP>:8080
# - Grafana: http://<GRAFANA-EXTERNAL-IP>:3001
```

### Using Port Forwarding (Local/Development)

For local clusters or when LoadBalancer is not available:

```bash
# Forward frontend
kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx &

# Forward API
kubectl port-forward svc/api-service 8080:8080 -n genx-fx &

# Forward Grafana
kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx &

# Access:
# - Frontend: http://localhost:3000
# - API: http://localhost:8080
# - API Docs: http://localhost:8080/docs
# - Grafana: http://localhost:3001 (admin/admin)
```

### Using NodePort (Alternative)

To use NodePort instead of LoadBalancer, modify service files:

```yaml
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080  # Choose port in range 30000-32767
```

## 🔄 Updates and Maintenance

### Update Deployment

```bash
# Update image
kubectl set image deployment/api api=genxdbx/genxdbxfx1:api-new-version -n genx-fx

# Or apply updated manifest
kubectl apply -f k8s/deployments/api-deployment.yaml

# Check rollout status
kubectl rollout status deployment/api -n genx-fx

# Rollback if needed
kubectl rollout undo deployment/api -n genx-fx
```

### Scale Deployments

```bash
# Scale API
kubectl scale deployment/api --replicas=3 -n genx-fx

# Scale Frontend
kubectl scale deployment/frontend --replicas=3 -n genx-fx

# Auto-scale (if metrics-server is installed)
kubectl autoscale deployment api --cpu-percent=70 --min=2 --max=10 -n genx-fx
```

### Update Secrets

```bash
# Edit secrets
kubectl edit secret genx-fx-secrets -n genx-fx

# Or delete and recreate
kubectl delete secret genx-fx-secrets -n genx-fx
kubectl apply -f k8s/configs/secrets.yaml

# Restart pods to use new secrets
kubectl rollout restart deployment/api -n genx-fx
```

## 🧹 Cleanup

### Delete All Resources

```bash
# Delete entire namespace (removes everything)
kubectl delete namespace genx-fx

# Or delete resources individually
kubectl delete -f k8s/deployments/
kubectl delete -f k8s/services/
kubectl delete -f k8s/volumes/
kubectl delete -f k8s/configs/
kubectl delete -f k8s/namespace.yaml
```

### Delete Specific Deployment

```bash
kubectl delete deployment api -n genx-fx
kubectl delete service api-service -n genx-fx
```

## 🔒 Production Considerations

### Security

1. **Secrets Management**: Use external secret managers
   - Kubernetes Secrets (encrypted at rest)
   - HashiCorp Vault
   - AWS Secrets Manager / GCP Secret Manager
   - Sealed Secrets

2. **Network Policies**: Restrict pod-to-pod communication
   ```bash
   kubectl apply -f k8s/network-policies/
   ```

3. **Pod Security**: Use Pod Security Standards
   - Use non-root containers
   - Read-only root filesystem
   - Drop capabilities

4. **RBAC**: Implement Role-Based Access Control
   ```bash
   kubectl apply -f k8s/rbac/
   ```

### High Availability

1. **Multi-node cluster**: Deploy across multiple nodes
2. **Pod Disruption Budgets**: Ensure availability during updates
3. **Multiple replicas**: Run multiple instances of stateless services
4. **Database replication**: Set up MySQL replication for HA

### Ingress and SSL

1. **Install Ingress Controller**:
   ```bash
   # NGINX Ingress
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
   ```

2. **Create Ingress Resource**:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: genx-fx-ingress
     namespace: genx-fx
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-prod
   spec:
     tls:
     - hosts:
       - genxfx.example.com
       - api.genxfx.example.com
       secretName: genx-fx-tls
     rules:
     - host: genxfx.example.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: frontend-service
               port:
                 number: 3000
     - host: api.genxfx.example.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: api-service
               port:
                 number: 8080
   ```

3. **Install cert-manager for SSL**:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

### Monitoring and Logging

1. **Prometheus + Grafana**: Already included
2. **ELK Stack**: For centralized logging
3. **Jaeger**: For distributed tracing

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Check events
kubectl get events -n genx-fx --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name> -n genx-fx

# Check logs
kubectl logs <pod-name> -n genx-fx --previous
```

### Database Connection Issues

```bash
# Test MySQL connection from API pod
kubectl exec -it deployment/api -n genx-fx -- /bin/bash
mysql -h mysql-service -u genx_user -p genxdb_fx_db

# Check if MySQL is ready
kubectl get pod -l app=mysql -n genx-fx
```

### Storage Issues

```bash
# Check PVC status
kubectl get pvc -n genx-fx

# Check PV
kubectl get pv

# Describe PVC for errors
kubectl describe pvc mysql-pvc -n genx-fx
```

### Image Pull Issues

```bash
# Check image pull secrets
kubectl get secrets -n genx-fx

# Create Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=genxdbx \
  --docker-password=<password> \
  --docker-email=genxdbxfx1@gmail.com \
  -n genx-fx

# Add to deployment
spec:
  imagePullSecrets:
  - name: regcred
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [GenX FX Main Documentation](../README.md)

## 🆘 Support

For issues or questions:
1. Check pod logs: `kubectl logs -f <pod-name> -n genx-fx`
2. Review Kubernetes events: `kubectl get events -n genx-fx`
3. Open an issue on GitHub
4. Contact support: admin@genxdbxfx1.com
