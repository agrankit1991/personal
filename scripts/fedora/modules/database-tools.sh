#!/bin/bash

# Database Tools Module
# Install database servers and management tools

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Database GUI tools via Flatpak
DB_GUI_TOOLS=(
    "io.dbeaver.DBeaverCommunity:DBeaver Community"
    "com.axosoft.GitKraken:GitKraken (Git + DB)"
)

# Install PostgreSQL
install_postgresql() {
    simple_header "PostgreSQL Installation"
    
    if dnf_package_installed "postgresql-server"; then
        info "PostgreSQL is already installed"
        if ! confirm "Reconfigure PostgreSQL?"; then
            return 0
        fi
    fi
    
    if confirm "Install PostgreSQL?"; then
        install_dnf_package "postgresql-server" "PostgreSQL Server"
        install_dnf_package "postgresql-contrib" "PostgreSQL Additional Modules"
        install_dnf_package "postgresql-devel" "PostgreSQL Development Headers"
        
        if dnf_package_installed "postgresql-server"; then
            # Initialize database
            if confirm "Initialize PostgreSQL database?"; then
                show_progress "Initializing PostgreSQL database"
                sudo postgresql-setup --initdb
                show_success "PostgreSQL database initialized"
            fi
            
            # Enable and start service
            if confirm "Enable and start PostgreSQL service?"; then
                show_progress "Starting PostgreSQL service"
                sudo systemctl enable --now postgresql
                show_success "PostgreSQL service started"
                
                info "PostgreSQL is running on port 5432"
                info "Default superuser: postgres"
                info "Set password with: sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'your_password';\""
            fi
        fi
    else
        warn "Skipping PostgreSQL installation"
    fi
    
    echo
}

# Install MySQL/MariaDB
install_mariadb() {
    simple_header "MariaDB Installation"
    
    if dnf_package_installed "mariadb-server"; then
        info "MariaDB is already installed"
        if ! confirm "Reconfigure MariaDB?"; then
            return 0
        fi
    fi
    
    if confirm "Install MariaDB (MySQL compatible)?"; then
        install_dnf_package "mariadb-server" "MariaDB Server"
        install_dnf_package "mariadb" "MariaDB Client"
        install_dnf_package "mariadb-devel" "MariaDB Development Headers"
        
        if dnf_package_installed "mariadb-server"; then
            # Enable and start service
            if confirm "Enable and start MariaDB service?"; then
                show_progress "Starting MariaDB service"
                sudo systemctl enable --now mariadb
                show_success "MariaDB service started"
                
                # Secure installation
                if confirm "Run secure installation (recommended)?"; then
                    info "Running mysql_secure_installation..."
                    sudo mysql_secure_installation
                fi
                
                info "MariaDB is running on port 3306"
            fi
        fi
    else
        warn "Skipping MariaDB installation"
    fi
    
    echo
}

# Install Redis
install_redis() {
    simple_header "Redis Installation"
    
    if dnf_package_installed "redis"; then
        info "Redis is already installed"
        if ! confirm "Reconfigure Redis?"; then
            return 0
        fi
    fi
    
    if confirm "Install Redis?"; then
        install_dnf_package "redis" "Redis Server"
        
        if dnf_package_installed "redis"; then
            # Enable and start service
            if confirm "Enable and start Redis service?"; then
                show_progress "Starting Redis service"
                sudo systemctl enable --now redis
                show_success "Redis service started"
                
                info "Redis is running on port 6379"
            fi
        fi
    else
        warn "Skipping Redis installation"
    fi
    
    echo
}

# Install MongoDB
install_mongodb() {
    simple_header "MongoDB Installation"
    
    if command_exists mongod; then
        info "MongoDB is already installed"
        if ! confirm "Reconfigure MongoDB?"; then
            return 0
        fi
    fi
    
    if confirm "Install MongoDB?"; then
        show_progress "Setting up MongoDB repository"
        
        # Create MongoDB repo file
        cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF
        
        show_progress "Installing MongoDB"
        sudo dnf install -y mongodb-org
        
        if command_exists mongod; then
            show_success "MongoDB installed successfully"
            
            # Enable and start service
            if confirm "Enable and start MongoDB service?"; then
                show_progress "Starting MongoDB service"
                sudo systemctl enable --now mongod
                show_success "MongoDB service started"
                
                info "MongoDB is running on port 27017"
            fi
        else
            show_error "Failed to install MongoDB"
        fi
    else
        warn "Skipping MongoDB installation"
    fi
    
    echo
}

# Install SQLite
install_sqlite() {
    simple_header "SQLite Installation"
    
    if dnf_package_installed "sqlite"; then
        info "SQLite is already installed"
        return 0
    fi
    
    if confirm "Install SQLite?"; then
        install_dnf_package "sqlite" "SQLite Database"
        install_dnf_package "sqlite-devel" "SQLite Development Headers"
    else
        warn "Skipping SQLite installation"
    fi
    
    echo
}

# Install database GUI tools
install_db_gui_tools() {
    simple_header "Database GUI Tools"
    
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Skipping GUI tools."
        return 1
    fi
    
    info "Available database GUI tools:"
    for tool_info in "${DB_GUI_TOOLS[@]}"; do
        local display_name="${tool_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for tool_info in "${DB_GUI_TOOLS[@]}"; do
        local app_id="${tool_info%%:*}"
        local display_name="${tool_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install database CLI tools
install_db_cli_tools() {
    simple_header "Database CLI Tools"
    
    # PostgreSQL client
    if confirm "Install PostgreSQL client (psql)?"; then
        install_dnf_package "postgresql" "PostgreSQL Client"
    fi
    
    # MySQL/MariaDB client
    if confirm "Install MySQL/MariaDB client?"; then
        if ! dnf_package_installed "mariadb"; then
            install_dnf_package "mariadb" "MariaDB Client"
        else
            info "MariaDB client is already installed"
        fi
    fi
    
    # Redis CLI
    if confirm "Install Redis CLI?"; then
        if ! command_exists redis-cli && ! dnf_package_installed "redis"; then
            install_dnf_package "redis" "Redis (includes CLI)"
        else
            info "Redis CLI is already installed"
        fi
    fi
    
    echo
}

# Show installed databases
list_installed_databases() {
    simple_header "Installed Database Tools"
    
    echo "Database Servers:"
    local servers=("postgresql" "mariadb" "redis" "mongod")
    for server in "${servers[@]}"; do
        if command_exists "$server"; then
            echo "  ✅ $server"
        fi
    done
    
    echo
    echo "Running Services:"
    local services=("postgresql" "mariadb" "redis" "mongod")
    for service in "${services[@]}"; do
        if sudo systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "  ✅ $service (running)"
        fi
    done
    
    echo
}

main() {
    box "Database Tools Installation"
    
    info "This module installs database servers and management tools"
    echo
    
    if ! confirm "Do you want to proceed with database tools installation?"; then
        warn "Database tools installation cancelled"
        exit 0
    fi
    
    echo
    
    # Database servers
    if confirm "Install database servers?"; then
        install_postgresql
        install_mariadb
        install_redis
        install_mongodb
        install_sqlite
    fi
    
    # CLI tools
    if confirm "Install database CLI tools?"; then
        install_db_cli_tools
    fi
    
    # GUI tools
    if confirm "Install database GUI tools?"; then
        install_db_gui_tools
    fi
    
    # Show installed
    list_installed_databases
    
    show_success "Database tools installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
