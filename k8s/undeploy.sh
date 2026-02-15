#!/bin/bash

# GenX FX Kubernetes Undeploy Script
# This script removes the GenX FX Trading Platform from Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  GenX FX Kubernetes Undeploy${NC}"
echo ""

# Confirmation prompt
echo -e "${RED}WARNING: This will remove all GenX FX resources from Kubernetes!${NC}"
echo -e "${RED}This includes all data, configurations, and persistent volumes.${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no) " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${GREEN}Aborted. No changes made.${NC}"
    exit 0
fi

echo -e "${YELLOW}Starting undeploy process...${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace genx-fx &> /dev/null; then
    echo -e "${YELLOW}Namespace 'genx-fx' does not exist. Nothing to undeploy.${NC}"
    exit 0
fi

# Delete all deployments
echo -e "${BLUE}Deleting deployments...${NC}"
kubectl delete deployments --all -n genx-fx --ignore-not-found=true

# Delete all services
echo -e "${BLUE}Deleting services...${NC}"
kubectl delete services --all -n genx-fx --ignore-not-found=true

# Wait for pods to terminate
echo -e "${BLUE}Waiting for pods to terminate...${NC}"
kubectl wait --for=delete pod --all -n genx-fx --timeout=120s || echo "Some pods may still be terminating"

# Delete PVCs
echo -e "${BLUE}Deleting persistent volume claims...${NC}"
kubectl delete pvc --all -n genx-fx --ignore-not-found=true

# Delete ConfigMaps
echo -e "${BLUE}Deleting configmaps...${NC}"
kubectl delete configmaps --all -n genx-fx --ignore-not-found=true

# Delete Secrets
echo -e "${BLUE}Deleting secrets...${NC}"
kubectl delete secrets --all -n genx-fx --ignore-not-found=true

# Delete namespace
echo -e "${BLUE}Deleting namespace...${NC}"
kubectl delete namespace genx-fx --ignore-not-found=true

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}✅ Undeploy completed successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}All GenX FX resources have been removed from Kubernetes.${NC}"
