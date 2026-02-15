# Kubernetes Quick Reference

## Quick Commands

### Deploy
```bash
cd k8s
./deploy.sh
```

### Check Status
```bash
kubectl get all -n genx-fx
kubectl get pods -n genx-fx -w
```

### Access Services (Port Forward)
```bash
# Frontend
kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx

# API
kubectl port-forward svc/api-service 8080:8080 -n genx-fx

# Grafana
kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx
```

### View Logs
```bash
# API
kubectl logs -f deployment/api -n genx-fx

# Frontend
kubectl logs -f deployment/frontend -n genx-fx

# Trading Bot
kubectl logs -f deployment/trading-bot -n genx-fx
```

### Update Secrets
```bash
kubectl edit secret genx-fx-secrets -n genx-fx
kubectl rollout restart deployment/api -n genx-fx
```

### Scale Services
```bash
kubectl scale deployment/api --replicas=3 -n genx-fx
kubectl scale deployment/frontend --replicas=3 -n genx-fx
```

### Undeploy
```bash
cd k8s
./undeploy.sh
```

## Service URLs

- **Frontend**: http://localhost:3000 (via port-forward)
- **API**: http://localhost:8080 (via port-forward)
- **API Docs**: http://localhost:8080/docs
- **Grafana**: http://localhost:3001 (via port-forward, default: admin/admin)

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name> -n genx-fx
kubectl logs <pod-name> -n genx-fx
```

### Database connection issues
```bash
kubectl exec -it deployment/api -n genx-fx -- /bin/bash
mysql -h mysql-service -u genx_user -p
```

### Check events
```bash
kubectl get events -n genx-fx --sort-by='.lastTimestamp'
```
