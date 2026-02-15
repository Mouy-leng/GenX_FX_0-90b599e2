# Makefile for GenX FX Kubernetes Operations

.PHONY: help validate deploy undeploy status logs shell port-forward clean

# Default target
help:
	@echo "GenX FX Kubernetes Operations"
	@echo ""
	@echo "Available targets:"
	@echo "  validate      - Validate Kubernetes manifests"
	@echo "  deploy        - Deploy to Kubernetes"
	@echo "  undeploy      - Remove from Kubernetes"
	@echo "  status        - Check deployment status"
	@echo "  logs          - View logs (specify service with SVC=api|frontend|trading-bot)"
	@echo "  shell         - Open shell in pod (specify service with SVC=api|frontend|trading-bot)"
	@echo "  port-forward  - Set up port forwarding for all services"
	@echo "  clean         - Clean up everything"

# Validate manifests
validate:
	@echo "Validating Kubernetes manifests..."
	@./validate.sh

# Deploy to Kubernetes
deploy:
	@echo "Deploying to Kubernetes..."
	@./deploy.sh

# Undeploy from Kubernetes
undeploy:
	@echo "Undeploying from Kubernetes..."
	@./undeploy.sh

# Check deployment status
status:
	@echo "Checking deployment status..."
	@kubectl get all -n genx-fx
	@echo ""
	@echo "Persistent Volumes:"
	@kubectl get pvc -n genx-fx

# View logs
logs:
	@if [ -z "$(SVC)" ]; then \
		echo "Please specify service with SVC=api|frontend|trading-bot|mysql|redis"; \
		echo "Example: make logs SVC=api"; \
		exit 1; \
	fi
	@kubectl logs -f deployment/$(SVC) -n genx-fx

# Open shell in pod
shell:
	@if [ -z "$(SVC)" ]; then \
		echo "Please specify service with SVC=api|frontend|trading-bot"; \
		echo "Example: make shell SVC=api"; \
		exit 1; \
	fi
	@kubectl exec -it deployment/$(SVC) -n genx-fx -- /bin/bash

# Set up port forwarding
port-forward:
	@echo "Setting up port forwarding..."
	@echo "Frontend will be available at http://localhost:3000"
	@echo "API will be available at http://localhost:8080"
	@echo "Grafana will be available at http://localhost:3001"
	@echo ""
	@echo "Press Ctrl+C to stop"
	@kubectl port-forward svc/frontend-service 3000:3000 -n genx-fx & \
	kubectl port-forward svc/api-service 8080:8080 -n genx-fx & \
	kubectl port-forward svc/grafana-service 3001:3001 -n genx-fx & \
	wait

# Clean everything
clean: undeploy
	@echo "Cleaned up all resources"

# Scale replicas
scale:
	@if [ -z "$(SVC)" ] || [ -z "$(REPLICAS)" ]; then \
		echo "Please specify service and replicas"; \
		echo "Example: make scale SVC=api REPLICAS=3"; \
		exit 1; \
	fi
	@kubectl scale deployment/$(SVC) --replicas=$(REPLICAS) -n genx-fx

# Restart deployment
restart:
	@if [ -z "$(SVC)" ]; then \
		echo "Please specify service with SVC=api|frontend|trading-bot"; \
		echo "Example: make restart SVC=api"; \
		exit 1; \
	fi
	@kubectl rollout restart deployment/$(SVC) -n genx-fx
