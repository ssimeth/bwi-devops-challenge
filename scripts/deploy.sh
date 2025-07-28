#!/bin/bash

# ==============================================
# BWI KVInfoSys Deployment Script
# ==============================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="kv-infosys"
NAMESPACE="kv-infosys"
REGION="eu-de"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if required tools are installed
    local tools=("kubectl" "terraform" "otc" "docker")
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            log_error "$tool is not installed or not in PATH"
            exit 1
        fi
    done
    
    # Check if kubeconfig is available
    if ! kubectl cluster-info &> /dev/null; then
        log_error "kubectl cannot connect to cluster. Please check your kubeconfig."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Check if required environment variables are set
    if [[ -z "${TF_VAR_otc_tenant_id:-}" ]] || [[ -z "${TF_VAR_otc_access_key:-}" ]] || [[ -z "${TF_VAR_otc_secret_key:-}" ]]; then
        log_error "Required Terraform variables not set. Please set TF_VAR_otc_tenant_id, TF_VAR_otc_access_key, and TF_VAR_otc_secret_key"
        exit 1
    fi
    
    terraform init
    terraform plan -out=tfplan
    
    read -p "Apply Terraform plan? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
        log_success "Infrastructure deployed successfully"
    else
        log_warning "Infrastructure deployment skipped"
    fi
    
    cd ..
}

deploy_application() {
    log_info "Deploying application to Kubernetes..."
    
    # Create namespace if it doesn't exist
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply Kubernetes manifests
    kubectl apply -f k8s/
    
    # Wait for deployments to be ready
    log_info "Waiting for deployments to be ready..."
    kubectl rollout status deployment/postgres-deployment -n $NAMESPACE --timeout=300s
    kubectl rollout status deployment/backend-deployment -n $NAMESPACE --timeout=300s
    kubectl rollout status deployment/frontend-deployment -n $NAMESPACE --timeout=300s
    
    log_success "Application deployed successfully"
}

check_health() {
    log_info "Performing health checks..."
    
    # Check pod status
    kubectl get pods -n $NAMESPACE
    
    # Check services
    kubectl get services -n $NAMESPACE
    
    # Check ingress
    kubectl get ingress -n $NAMESPACE
    
    # Test backend health endpoint
    log_info "Testing backend health..."
    kubectl port-forward service/backend-service 3000:3000 -n $NAMESPACE &
    PF_PID=$!
    sleep 5
    
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log_success "Backend health check passed"
    else
        log_error "Backend health check failed"
    fi
    
    kill $PF_PID 2>/dev/null || true
    
    # Get external IP
    EXTERNAL_IP=$(kubectl get ingress $PROJECT_NAME-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    if [[ "$EXTERNAL_IP" != "pending" && -n "$EXTERNAL_IP" ]]; then
        log_success "Application accessible at: http://$EXTERNAL_IP"
    else
        log_warning "External IP not yet assigned. Check ingress status later."
    fi
}

cleanup() {
    log_info "Cleaning up resources..."
    
    read -p "This will delete all Kubernetes resources. Continue? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace $NAMESPACE --ignore-not-found=true
        log_success "Kubernetes resources cleaned up"
    fi
    
    read -p "Also destroy Terraform infrastructure? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd terraform
        terraform destroy -auto-approve
        cd ..
        log_success "Infrastructure destroyed"
    fi
}

rollback() {
    log_info "Rolling back to previous version..."
    
    kubectl rollout undo deployment/backend-deployment -n $NAMESPACE
    kubectl rollout undo deployment/frontend-deployment -n $NAMESPACE
    
    kubectl rollout status deployment/backend-deployment -n $NAMESPACE --timeout=300s
    kubectl rollout status deployment/frontend-deployment -n $NAMESPACE --timeout=300s
    
    log_success "Rollback completed"
}

show_logs() {
    local component=${1:-"all"}
    
    case $component in
        backend)
            kubectl logs -f deployment/backend-deployment -n $NAMESPACE
            ;;
        frontend)
            kubectl logs -f deployment/frontend-deployment -n $NAMESPACE
            ;;
        database)
            kubectl logs -f deployment/postgres-deployment -n $NAMESPACE
            ;;
        all)
            log_info "Backend logs:"
            kubectl logs --tail=10 deployment/backend-deployment -n $NAMESPACE
            log_info "Frontend logs:"
            kubectl logs --tail=10 deployment/frontend-deployment -n $NAMESPACE
            log_info "Database logs:"
            kubectl logs --tail=10 deployment/postgres-deployment -n $NAMESPACE
            ;;
        *)
            log_error "Unknown component: $component"
            log_info "Available components: backend, frontend, database, all"
            ;;
    esac
}

show_help() {
    echo "BWI KVInfoSys Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy-infra    Deploy infrastructure with Terraform"
    echo "  deploy-app      Deploy application to Kubernetes"
    echo "  deploy-all      Deploy both infrastructure and application"
    echo "  health          Check application health"
    echo "  logs [COMPONENT]  Show logs (backend|frontend|database|all)"
    echo "  rollback        Rollback to previous version"
    echo "  cleanup         Clean up all resources"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy-all"
    echo "  $0 logs backend"
    echo "  $0 health"
}

# Main script logic
case "${1:-help}" in
    deploy-infra)
        check_prerequisites
        deploy_infrastructure
        ;;
    deploy-app)
        check_prerequisites
        deploy_application
        check_health
        ;;
    deploy-all)
        check_prerequisites
        deploy_infrastructure
        deploy_application
        check_health
        ;;
    health)
        check_prerequisites
        check_health
        ;;
    logs)
        check_prerequisites
        show_logs "${2:-all}"
        ;;
    rollback)
        check_prerequisites
        rollback
        ;;
    cleanup)
        check_prerequisites
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
