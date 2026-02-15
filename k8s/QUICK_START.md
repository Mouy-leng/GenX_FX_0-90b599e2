# Quick Start Guide - Kubernetes Deployment

## 🎯 Goal
Deploy GenX FX Trading Platform to Kubernetes in 5 minutes.

## 📋 Prerequisites Checklist
- [ ] Kubernetes cluster running (Minikube/GKE/EKS/AKS)
- [ ] kubectl installed and configured
- [ ] Docker images built or available in registry
- [ ] Secrets updated in `k8s/configs/secrets.yaml`

## 🚀 Quick Deploy

### Step 1: Update Secrets (REQUIRED!)
```bash
# Generate secure passwords
openssl rand -hex 32  # Copy for SECRET_KEY
openssl rand -hex 32  # Copy for JWT_SECRET

# Edit secrets file
nano k8s/configs/secrets.yaml

# Update at minimum:
# - MYSQL_ROOT_PASSWORD
# - MYSQL_PASSWORD  
# - SECRET_KEY
# - MT5_PASSWORD (if using MT5)
# - API keys (if using external services)
```

### Step 2: Deploy
```bash
cd k8s
./deploy.sh
```

### Step 3: Wait for Ready
```bash
kubectl get pods -n genx-fx -w
# Wait until all pods show "Running" status
# Press Ctrl+C when done
```

### Step 4: Access Services
```bash
# Open 3 terminals and run:
kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx
kubectl port-forward svc/api-service 8080:8080 -n genx-fx  
kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx
```

### Step 5: Open Browser
- **Frontend**: http://localhost:3000
- **API Docs**: http://localhost:8080/docs
- **Grafana**: http://localhost:3001 (admin/admin)

## ✅ Verify Deployment

```bash
# Check all services are running
kubectl get all -n genx-fx

# Should see:
# ✓ 5 deployments (api, frontend, trading-bot, mysql, redis, grafana)
# ✓ 5 services
# ✓ Multiple pods (all Running)
```

## 🛠️ Common Commands

```bash
# View logs
kubectl logs -f deployment/api -n genx-fx

# Check status
kubectl get pods -n genx-fx

# Restart service
kubectl rollout restart deployment/api -n genx-fx

# Scale service
kubectl scale deployment/api --replicas=3 -n genx-fx

# Remove everything
cd k8s && ./undeploy.sh
```

## 🆘 Troubleshooting

### Pods stuck in "Pending"
```bash
kubectl describe pod <pod-name> -n genx-fx
# Check events for storage or resource issues
```

### Can't connect to services
```bash
# Verify port-forward is running
ps aux | grep "port-forward"

# Restart port-forward
pkill -f "port-forward"
kubectl port-forward svc/api-service 8080:8080 -n genx-fx &
```

### Database connection errors
```bash
# Check MySQL is ready
kubectl get pod -l app=mysql -n genx-fx
kubectl logs deployment/mysql -n genx-fx

# Test connection
kubectl exec -it deployment/api -n genx-fx -- /bin/bash
mysql -h mysql-service -u genx_user -p
```

## 📚 Next Steps

1. Configure API keys in Grafana
2. Set up monitoring dashboards
3. Test trading functionality
4. Review [KUBERNETES_DEPLOYMENT.md](../KUBERNETES_DEPLOYMENT.md) for advanced topics

## 🎉 Success!

Your GenX FX Trading Platform is now running on Kubernetes!
