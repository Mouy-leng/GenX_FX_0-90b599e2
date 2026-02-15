# GenX FX Kubernetes Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Internet / Users                               │
└──────────────────────────┬──────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                  Load Balancers (Kubernetes Services)                    │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────────────────────┐   │
│  │  Frontend    │  │   API       │  │      Grafana Monitoring      │   │
│  │  Port 3000   │  │  Port 8080  │  │         Port 3001            │   │
│  └──────────────┘  └─────────────┘  └──────────────────────────────┘   │
└────────┬────────────────┬──────────────────────┬───────────────────────┘
         │                │                      │
         ▼                ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Namespace: genx-fx                         │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │                    Application Layer                            │     │
│  │  ┌──────────────┐  ┌─────────────┐  ┌────────────────────┐    │     │
│  │  │  Frontend    │  │   API       │  │    Trading Bot     │    │     │
│  │  │  (2 pods)    │  │  (2 pods)   │  │    (1 pod)         │    │     │
│  │  │  React UI    │  │  FastAPI    │  │  Automated Trading │    │     │
│  │  └──────────────┘  └─────┬───────┘  └────────┬───────────┘    │     │
│  │                           │                   │                 │     │
│  └───────────────────────────┼───────────────────┼─────────────────┘     │
│                              │                   │                       │
│                              ▼                   ▼                       │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │                      Data Layer                                 │     │
│  │  ┌──────────────────────┐      ┌──────────────────────┐       │     │
│  │  │      MySQL DB        │      │      Redis Cache      │       │     │
│  │  │    (1 pod)           │      │      (1 pod)          │       │     │
│  │  │  ClusterIP:3306      │      │   ClusterIP:6379      │       │     │
│  │  │                      │      │                       │       │     │
│  │  │  ┌────────────────┐  │      │  ┌─────────────────┐ │       │     │
│  │  │  │   PVC (10Gi)   │  │      │  │   PVC (5Gi)     │ │       │     │
│  │  │  │  mysql-pvc     │  │      │  │   redis-pvc     │ │       │     │
│  │  │  └────────────────┘  │      │  └─────────────────┘ │       │     │
│  │  └──────────────────────┘      └──────────────────────┘       │     │
│  └────────────────────────────────────────────────────────────────┘     │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │                   Monitoring Layer                              │     │
│  │  ┌──────────────────────┐                                      │     │
│  │  │      Grafana         │                                      │     │
│  │  │     (1 pod)          │                                      │     │
│  │  │  LoadBalancer:3001   │                                      │     │
│  │  │                      │                                      │     │
│  │  │  ┌────────────────┐  │                                      │     │
│  │  │  │   PVC (5Gi)    │  │                                      │     │
│  │  │  │  grafana-pvc   │  │                                      │     │
│  │  │  └────────────────┘  │                                      │     │
│  │  └──────────────────────┘                                      │     │
│  └────────────────────────────────────────────────────────────────┘     │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │                   Shared Storage                                │     │
│  │  ┌──────────────────┐      ┌──────────────────┐               │     │
│  │  │  Logs PVC        │      │   Data PVC       │               │     │
│  │  │  (10Gi, RWX)     │      │   (20Gi, RWX)    │               │     │
│  │  │  logs-pvc        │      │   data-pvc       │               │     │
│  │  └──────────────────┘      └──────────────────┘               │     │
│  └────────────────────────────────────────────────────────────────┘     │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │              Configuration & Secrets                            │     │
│  │  ┌──────────────────┐  ┌────────────────┐  ┌───────────────┐ │     │
│  │  │   ConfigMap      │  │    Secrets     │  │  MySQL Init   │ │     │
│  │  │  genx-fx-config  │  │ genx-fx-secrets│  │   ConfigMap   │ │     │
│  │  └──────────────────┘  └────────────────┘  └───────────────┘ │     │
│  └────────────────────────────────────────────────────────────────┘     │
└───────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### Frontend (React)
- **Purpose**: Web-based user interface
- **Replicas**: 2 (load balanced)
- **Resources**: 256Mi-1Gi RAM, 100m-500m CPU
- **Health Checks**: HTTP GET on port 3000

### API Backend (FastAPI)
- **Purpose**: REST API for trading operations
- **Replicas**: 2 (load balanced)
- **Resources**: 512Mi-2Gi RAM, 250m-1000m CPU
- **Health Checks**: HTTP GET /health on port 8080
- **Dependencies**: MySQL, Redis

### Trading Bot (Python)
- **Purpose**: Automated trade execution
- **Replicas**: 1 (singleton)
- **Resources**: 512Mi-2Gi RAM, 250m-1000m CPU
- **Dependencies**: MySQL, Redis, API

### MySQL Database
- **Purpose**: Primary data store
- **Replicas**: 1 (with persistent storage)
- **Storage**: 10Gi persistent volume
- **Resources**: 512Mi-1Gi RAM, 250m-500m CPU
- **Initialization**: Automated schema and data setup

### Redis Cache
- **Purpose**: Caching and session storage
- **Replicas**: 1 (with persistent storage)
- **Storage**: 5Gi persistent volume
- **Resources**: 256Mi-512Mi RAM, 100m-200m CPU

### Grafana Monitoring
- **Purpose**: Metrics visualization and monitoring
- **Replicas**: 1 (with persistent storage)
- **Storage**: 5Gi persistent volume
- **Resources**: 256Mi-512Mi RAM, 100m-250m CPU
- **Default Credentials**: admin/admin

## Storage Architecture

### Persistent Volumes
- **mysql-pvc**: 10Gi, RWO (ReadWriteOnce)
- **redis-pvc**: 5Gi, RWO
- **grafana-pvc**: 5Gi, RWO
- **logs-pvc**: 10Gi, RWX (ReadWriteMany, shared across pods)
- **data-pvc**: 20Gi, RWX (shared across pods)

Total Storage: **50Gi**

## Network Flow

1. **User → Frontend**: User accesses web UI via LoadBalancer (port 3000)
2. **Frontend → API**: Frontend calls API via internal service
3. **API → MySQL**: API reads/writes data to MySQL database
4. **API → Redis**: API uses Redis for caching and sessions
5. **Trading Bot → API**: Bot calls API for signal processing
6. **Trading Bot → MySQL**: Direct database access for trade records
7. **Admin → Grafana**: Monitoring via LoadBalancer (port 3001)

## Scaling Strategy

### Horizontal Scaling
- **Frontend**: Can scale to 10+ replicas
- **API**: Can scale to 10+ replicas
- **Trading Bot**: Keep at 1 replica (singleton pattern)

### Vertical Scaling
- Adjust resource limits based on load
- Use metrics-server for monitoring

### Auto-scaling
```bash
kubectl autoscale deployment api --cpu-percent=70 --min=2 --max=10 -n genx-fx
```

## High Availability

### Application Layer
- Multiple replicas for stateless services
- Load balancing via Kubernetes services
- Health checks and automatic restarts

### Data Layer
- Persistent volumes survive pod restarts
- Regular backups recommended
- Future: MySQL replication for HA

### Network
- Multiple service endpoints
- LoadBalancer distribution
- Internal service discovery via DNS

## Security Layers

1. **Namespace Isolation**: Dedicated `genx-fx` namespace
2. **Network Policies**: (Future) Restrict pod-to-pod communication
3. **Secrets Management**: Sensitive data in Kubernetes Secrets
4. **RBAC**: (Future) Role-based access control
5. **Pod Security**: Non-root containers, read-only filesystems where possible
