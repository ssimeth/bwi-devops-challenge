[![CI/CD Pipeline](https://github.com/ssimeth/bwi-devops-challenge/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/ssimeth/bwi-devops-challenge/actions/workflows/ci-cd.yml)

# BWI DevOps Challenge - KVInfoSysBund

## Projektübersicht

Dieses Projekt demonstriert eine vollständige DevOps-Lösung für das **KVInfoSysBund** - ein webbasiertes Geo-Informationssystem zur Krisenbewältigung im Behördenumfeld.

### Architektur

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │    │   Backend   │    │  Database   │
│   (React)   │───▶│  (Node.js)  │───▶│(PostgreSQL) │
│   nginx     │    │   Express   │    │  + PostGIS  │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Technologie Stack

- **Frontend**: React.js mit TypeScript, served by nginx
- **Backend**: Node.js mit Express und TypeScript
- **Database**: PostgreSQL (PostGIS für Geodaten)
- **Container**: Docker
- **Orchestrierung**: Kubernetes
- **Infrastructure**: Terraform (Open Telekom Cloud)
- **CI/CD**: GitHub Actions

## Projektstruktur

```
├── .github/workflows/    # GitHub Actions Pipelines
├── terraform/            # Infrastructure as Code
├── k8s/                  # Kubernetes Manifeste
├── backend/              # Node.js API
├── frontend/             # React Application
├── docs/                 # Dokumentation
└── scripts/              # Helper Scripts
```

### Voraussetzungen

- Docker
- kubectl
- terraform
- Node.js 18+
- Open Telekom Cloud Account

### Infrastructure Deployment

```bash
# Terraform initialisieren
cd terraform
cp terrform.tfvars.example terrform.tfvars
terraform init
terraform plan
terraform apply

# Kubeconfig wird von Terraform output bereitgestellt

```

## CI/CD Pipeline

Die GitHub Actions Pipeline umfasst:

1. **Validate**: Linting, Tests, Security Scans
2. **Build**: Container Images erstellen
3. **Test**: Integration Tests
4. **Deploy**: Automatisches Deployment
5. **Monitor**: Health Checks

## Security

- Container Security Scanning 
- Kubernetes Network Policies (TODO)
- Secrets Management

## Roadmap

- Ingress mit automatischer Zertifikatsverwaltung (ACME + cert-manger)
- Slack Notification
- Prometheus Monitoring Stack
- Grafana Dashboards
- ELK Stack für Logging
- Istio Service Mesh
- Jaeger für Distributed Tracing
- Neuvector für Lifecycle Security
