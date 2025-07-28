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
- **Database**: PostgreSQL mit PostGIS für Geodaten
- **Container**: Docker
- **Orchestrierung**: Kubernetes
- **Infrastructure**: Terraform (Open Telekom Cloud)
- **CI/CD**: GitHub Actions

## Projektstruktur

```
├── .github/workflows/     # GitHub Actions Pipelines
├── terraform/            # Infrastructure as Code
├── k8s/                 # Kubernetes Manifeste
├── backend/             # Node.js API
├── frontend/            # React Application
├── docs/               # Dokumentation
└── scripts/           # Helper Scripts
```

## Quick Start

### Voraussetzungen

- Docker & Docker Compose
- kubectl
- terraform
- Node.js 18+
- Open Telekom Cloud Account

### Lokale Entwicklung

```bash
# Repository klonen
git clone <repository-url>
cd bwi-devops-challenge

# Backend starten
cd backend
npm install
npm run dev

# Frontend starten (neues Terminal)
cd frontend
npm install
npm start

# Database (Docker)
docker-compose up postgres
```

### Infrastructure Deployment

```bash
# Terraform initialisieren
cd terraform
cp terrform.tfvars.example terrform.tfvars
terraform init
terraform plan
terraform apply

# Kubernetes Cluster verbinden
# (wird von Terraform output bereitgestellt)

# Application deployen
kubectl apply -f k8s/
```

## CI/CD Pipeline

Die GitHub Actions Pipeline umfasst:

1. **Validate**: Linting, Tests, Security Scans
2. **Build**: Container Images erstellen
3. **Test**: Integration Tests
4. **Deploy**: Automatisches Deployment
5. **Monitor**: Health Checks und Notifications

## Security

- Container Security Scanning
- Kubernetes Network Policies
- Secrets Management
- RBAC Implementation
- BSI Grundschutz Compliance

## Monitoring

- Prometheus Metriken
- Grafana Dashboards
- ELK Stack für Logging
- Jaeger für Distributed Tracing

## Dokumentation

Weitere Dokumentation finden Sie in:
- [Architecture Decision Records](docs/adr/)
- [Deployment Guide](docs/deployment.md)
- [Security Guide](docs/security.md)
- [API Documentation](docs/api.md)

## Kontakt

Entwickelt für die BWI GmbH - Software Data Solutions & Analytics Team
