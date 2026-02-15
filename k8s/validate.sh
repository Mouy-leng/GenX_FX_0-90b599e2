#!/bin/bash

# Kubernetes Manifest Validation Script
# This script validates Kubernetes manifests without deploying them

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating Kubernetes Manifests${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    echo "This script requires kubectl to validate manifests"
    echo "You can still deploy the manifests, but validation is recommended"
    exit 1
fi

echo -e "${GREEN}✅ kubectl is installed${NC}"
echo ""

# Function to validate a manifest
validate_manifest() {
    local file=$1
    echo -e "${YELLOW}Validating: ${file}${NC}"
    
    if kubectl apply --dry-run=client -f "$file" &> /dev/null; then
        echo -e "${GREEN}✅ Valid${NC}"
        return 0
    else
        echo -e "${RED}❌ Invalid${NC}"
        kubectl apply --dry-run=client -f "$file"
        return 1
    fi
}

errors=0

# Validate all manifests
echo -e "${BLUE}Namespace:${NC}"
validate_manifest "k8s/namespace.yaml" || ((errors++))
echo ""

echo -e "${BLUE}ConfigMaps:${NC}"
validate_manifest "k8s/configs/configmap.yaml" || ((errors++))
validate_manifest "k8s/configs/mysql-init-configmap.yaml" || ((errors++))
echo ""

echo -e "${BLUE}Secrets:${NC}"
validate_manifest "k8s/configs/secrets.yaml" || ((errors++))
echo ""

echo -e "${BLUE}Persistent Volumes:${NC}"
validate_manifest "k8s/volumes/persistent-volumes.yaml" || ((errors++))
echo ""

echo -e "${BLUE}Deployments:${NC}"
for deployment in k8s/deployments/*.yaml; do
    validate_manifest "$deployment" || ((errors++))
done
echo ""

echo -e "${BLUE}Services:${NC}"
for service in k8s/services/*.yaml; do
    validate_manifest "$service" || ((errors++))
done
echo ""

# Summary
echo "========================================="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✅ All manifests are valid!${NC}"
    echo -e "${GREEN}Ready to deploy to Kubernetes${NC}"
else
    echo -e "${RED}❌ Found $errors invalid manifest(s)${NC}"
    echo -e "${RED}Please fix the errors before deploying${NC}"
    exit 1
fi
echo "========================================="
