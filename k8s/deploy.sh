#!/bin/bash

# GenX FX Kubernetes Deployment Script
# This script deploys the GenX FX Trading Platform to a Kubernetes cluster

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying GenX FX Trading Platform to Kubernetes${NC}"

# Function to check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
        echo "Installation guide: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    echo -e "${GREEN}✅ kubectl is installed${NC}"
}

# Function to check cluster connection
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
        echo "Please ensure kubectl is configured with a valid cluster context"
        exit 1
    fi
    echo -e "${GREEN}✅ Connected to Kubernetes cluster${NC}"
    kubectl cluster-info
}

# Function to apply Kubernetes manifests
apply_manifests() {
    local resource_type=$1
    local path=$2
    
    echo -e "${YELLOW}Applying ${resource_type}...${NC}"
    kubectl apply -f "$path"
    echo -e "${GREEN}✅ ${resource_type} applied${NC}"
}

# Main deployment
main() {
    echo "========================================="
    echo "GenX FX Kubernetes Deployment"
    echo "========================================="
    echo ""
    
    # Check prerequisites
    check_kubectl
    check_cluster
    
    echo ""
    echo -e "${BLUE}Starting deployment...${NC}"
    echo ""
    
    # 1. Create namespace
    echo -e "${YELLOW}Step 1: Creating namespace...${NC}"
    apply_manifests "Namespace" "k8s/namespace.yaml"
    sleep 2
    
    # 2. Create ConfigMaps
    echo -e "${YELLOW}Step 2: Creating ConfigMaps...${NC}"
    apply_manifests "ConfigMaps" "k8s/configs/configmap.yaml"
    apply_manifests "MySQL Init ConfigMap" "k8s/configs/mysql-init-configmap.yaml"
    sleep 2
    
    # 3. Create Secrets
    echo -e "${YELLOW}Step 3: Creating Secrets...${NC}"
    echo -e "${RED}⚠️  WARNING: Please update the secrets in k8s/configs/secrets.yaml with your actual values!${NC}"
    read -p "Have you updated the secrets? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Please update the secrets before deploying.${NC}"
        exit 1
    fi
    apply_manifests "Secrets" "k8s/configs/secrets.yaml"
    sleep 2
    
    # 4. Create Persistent Volume Claims
    echo -e "${YELLOW}Step 4: Creating Persistent Volume Claims...${NC}"
    apply_manifests "PVCs" "k8s/volumes/persistent-volumes.yaml"
    sleep 5
    
    # Wait for PVCs to be bound
    echo -e "${YELLOW}Waiting for PVCs to be bound...${NC}"
    kubectl wait --for=condition=Bound pvc --all -n genx-fx --timeout=120s || echo "Some PVCs may still be pending"
    
    # 5. Deploy MySQL
    echo -e "${YELLOW}Step 5: Deploying MySQL database...${NC}"
    apply_manifests "MySQL Deployment" "k8s/deployments/mysql-deployment.yaml"
    apply_manifests "MySQL Service" "k8s/services/mysql-service.yaml"
    sleep 5
    
    # Wait for MySQL to be ready
    echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=mysql -n genx-fx --timeout=180s
    
    # 6. Deploy Redis
    echo -e "${YELLOW}Step 6: Deploying Redis cache...${NC}"
    apply_manifests "Redis Deployment" "k8s/deployments/redis-deployment.yaml"
    apply_manifests "Redis Service" "k8s/services/redis-service.yaml"
    sleep 5
    
    # Wait for Redis to be ready
    echo -e "${YELLOW}Waiting for Redis to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=redis -n genx-fx --timeout=120s
    
    # 7. Deploy API Backend
    echo -e "${YELLOW}Step 7: Deploying API backend...${NC}"
    apply_manifests "API Deployment" "k8s/deployments/api-deployment.yaml"
    apply_manifests "API Service" "k8s/services/api-service.yaml"
    sleep 5
    
    # Wait for API to be ready
    echo -e "${YELLOW}Waiting for API to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=api -n genx-fx --timeout=180s
    
    # 8. Deploy Frontend
    echo -e "${YELLOW}Step 8: Deploying Frontend...${NC}"
    apply_manifests "Frontend Deployment" "k8s/deployments/frontend-deployment.yaml"
    apply_manifests "Frontend Service" "k8s/services/frontend-service.yaml"
    sleep 5
    
    # 9. Deploy Trading Bot
    echo -e "${YELLOW}Step 9: Deploying Trading Bot...${NC}"
    apply_manifests "Trading Bot Deployment" "k8s/deployments/trading-bot-deployment.yaml"
    sleep 5
    
    # 10. Deploy Grafana Monitoring
    echo -e "${YELLOW}Step 10: Deploying Grafana monitoring...${NC}"
    apply_manifests "Grafana Deployment" "k8s/deployments/grafana-deployment.yaml"
    apply_manifests "Grafana Service" "k8s/services/grafana-service.yaml"
    
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    
    # Show deployment status
    echo -e "${BLUE}Deployment Status:${NC}"
    kubectl get all -n genx-fx
    
    echo ""
    echo -e "${BLUE}Service Endpoints:${NC}"
    kubectl get services -n genx-fx
    
    echo ""
    echo -e "${YELLOW}📝 Next Steps:${NC}"
    echo "1. Wait for all pods to be in 'Running' state: kubectl get pods -n genx-fx -w"
    echo "2. Check logs: kubectl logs -f <pod-name> -n genx-fx"
    echo "3. Access services via LoadBalancer IPs or use port-forwarding:"
    echo "   - Frontend: kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx"
    echo "   - API: kubectl port-forward svc/api-service 8080:8080 -n genx-fx"
    echo "   - Grafana: kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx"
    echo ""
    echo -e "${YELLOW}⚠️  Remember to:${NC}"
    echo "- Update secrets with actual API keys and passwords"
    echo "- Configure ingress for production deployment"
    echo "- Set up SSL/TLS certificates"
    echo "- Configure monitoring and alerting"
}

# Run main deployment
main "$@"
