    if [[ ! -d frontend/node_modules ]]; then
        log_error "Frontend dependencies not installed. Run: $0 install"
        exit 1
    fi
    
    cd frontend
    PORT=$FRONTEND_PORT npm start &
    FRONTEND_PID=$!
    cd ..
    
    echo $FRONTEND_PID > .frontend.pid
    log_success "Frontend started on port $FRONTEND_PORT (PID: $FRONTEND_PID)"
}

stop_services() {
    log_info "Stopping services..."
    
    # Stop backend
    if [[ -f .backend.pid ]]; then
        BACKEND_PID=$(cat .backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            kill $BACKEND_PID
            log_success "Backend stopped"
        fi
        rm -f .backend.pid
    fi
    
    # Stop frontend
    if [[ -f .frontend.pid ]]; then
        FRONTEND_PID=$(cat .frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            kill $FRONTEND_PID
            log_success "Frontend stopped"
        fi
        rm -f .frontend.pid
    fi
    
    # Stop database
    docker-compose -f docker-compose.dev.yml down
    log_success "Database stopped"
}

show_status() {
    log_info "Development environment status:"
    
    # Check database
    if docker-compose -f docker-compose.dev.yml ps postgres | grep -q "Up"; then
        log_success "Database: Running"
    else
        log_warning "Database: Stopped"
    fi
    
    # Check backend
    if [[ -f .backend.pid ]]; then
        BACKEND_PID=$(cat .backend.pid)
        if kill -0 $BACKEND_PID 2>/dev/null; then
            log_success "Backend: Running (PID: $BACKEND_PID)"
        else
            log_warning "Backend: Stopped"
            rm -f .backend.pid
        fi
    else
        log_warning "Backend: Stopped"
    fi
    
    # Check frontend
    if [[ -f .frontend.pid ]]; then
        FRONTEND_PID=$(cat .frontend.pid)
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            log_success "Frontend: Running (PID: $FRONTEND_PID)"
        else
            log_warning "Frontend: Stopped"
            rm -f .frontend.pid
        fi
    else
        log_warning "Frontend: Stopped"
    fi
    
    echo ""
    log_info "Access URLs:"
    log_info "Frontend: http://localhost:$FRONTEND_PORT"
    log_info "Backend API: http://localhost:$BACKEND_PORT"
    log_info "Database: postgresql://kvinfosys_user:dev_password@localhost:$DB_PORT/kvinfosys_dev"
}

run_tests() {
    local component=${1:-"all"}
    
    case $component in
        backend)
            log_info "Running backend tests..."
            cd backend
            npm test
            cd ..
            ;;
        frontend)
            log_info "Running frontend tests..."
            cd frontend
            npm test -- --coverage --watchAll=false
            cd ..
            ;;
        all)
            run_tests backend
            run_tests frontend
            ;;
        *)
            log_error "Unknown component: $component"
            log_info "Available components: backend, frontend, all"
            ;;
    esac
}

build_containers() {
    log_info "Building container images..."
    
    # Build backend
    log_info "Building backend image..."
    docker build -t kv-infosys-backend:dev ./backend
    
    # Build frontend
    log_info "Building frontend image..."
    docker build -t kv-infosys-frontend:dev ./frontend
    
    log_success "Container images built successfully"
}

clean_environment() {
    log_info "Cleaning development environment..."
    
    # Stop services
    stop_services
    
    # Remove node_modules
    read -p "Remove node_modules directories? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf backend/node_modules frontend/node_modules
        log_success "node_modules removed"
    fi
    
    # Remove Docker volumes
    read -p "Remove Docker volumes (database data will be lost)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f docker-compose.dev.yml down -v
        log_success "Docker volumes removed"
    fi
    
    # Clean Docker images
    read -p "Remove development Docker images? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rmi kv-infosys-backend:dev kv-infosys-frontend:dev 2>/dev/null || true
        log_success "Docker images removed"
    fi
}

show_logs() {
    local component=${1:-"all"}
    
    case $component in
        backend)
            if [[ -f .backend.pid ]]; then
                tail -f backend/logs/app.log 2>/dev/null || log_warning "Backend log file not found"
            else
                log_warning "Backend not running"
            fi
            ;;
        frontend)
            log_info "Frontend logs are shown in the terminal where it was started"
            ;;
        database)
            docker-compose -f docker-compose.dev.yml logs -f postgres
            ;;
        all)
            log_info "Use 'docker-compose -f docker-compose.dev.yml logs -f' to see all logs"
            ;;
        *)
            log_error "Unknown component: $component"
            log_info "Available components: backend, frontend, database, all"
            ;;
    esac
}

show_help() {
    echo "BWI KVInfoSys Local Development Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup           Setup local development environment"
    echo "  install         Install dependencies"
    echo "  start-db        Start database only"
    echo "  start-backend   Start backend development server"
    echo "  start-frontend  Start frontend development server"
    echo "  start-all       Start all services"
    echo "  stop            Stop all services"
    echo "  status          Show status of all services"
    echo "  test [COMPONENT] Run tests (backend|frontend|all)"
    echo "  build           Build container images"
    echo "  logs [COMPONENT] Show logs (backend|frontend|database|all)"
    echo "  clean           Clean development environment"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup"
    echo "  $0 start-all"
    echo "  $0 test backend"
    echo "  $0 logs database"
}

# Main script logic
case "${1:-help}" in
    setup)
        check_prerequisites
        setup_environment
        install_dependencies
        ;;
    install)
        check_prerequisites
        install_dependencies
        ;;
    start-db)
        check_prerequisites
        start_database
        ;;
    start-backend)
        check_prerequisites
        start_database
        start_backend
        ;;
    start-frontend)
        check_prerequisites
        start_frontend
        ;;
    start-all)
        check_prerequisites
        start_database
        start_backend
        start_frontend
        show_status
        ;;
    stop)
        stop_services
        ;;
    status)
        show_status
        ;;
    test)
        check_prerequisites
        run_tests "${2:-all}"
        ;;
    build)
        check_prerequisites
        build_containers
        ;;
    logs)
        show_logs "${2:-all}"
        ;;
    clean)
        clean_environment
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
