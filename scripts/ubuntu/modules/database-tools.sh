#!/bin/bash

# Database Tools Module
# Install database management tools and set up PostgreSQL

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Configuration - will be set by user input
DB_USER=""
DB_PASSWORD=""
SAMPLE_DB_NAME="sample_test_db"

# Get database credentials from user
get_database_credentials() {
    header "Database Configuration"
    echo "Please provide database credentials for PostgreSQL setup:"
    echo
    
    # Get database username
    while [[ -z "$DB_USER" ]]; do
        read -p "Enter database username: " DB_USER
        if [[ -z "$DB_USER" ]]; then
            error "Username cannot be empty. Please try again."
        fi
    done
    
    # Get database password
    while [[ -z "$DB_PASSWORD" ]]; do
        read -s -p "Enter database password: " DB_PASSWORD
        echo
        if [[ -z "$DB_PASSWORD" ]]; then
            error "Password cannot be empty. Please try again."
        fi
    done
    
    echo
    info "Configuration set:"
    info "  Username: $DB_USER"
    info "  Sample Test Database: $SAMPLE_DB_NAME (will be created for testing)"
    echo
    
    return 0
}

# Check if PostgreSQL is installed
is_postgresql_installed() {
    command -v psql >/dev/null 2>&1
}

# Check if DBeaver is installed
is_dbeaver_installed() {
    command -v dbeaver >/dev/null 2>&1 || [[ -f /opt/dbeaver/dbeaver ]] || dpkg -l | grep -q dbeaver-ce || flatpak list | grep -q io.dbeaver.DBeaverCommunity
}

# Install PostgreSQL
install_postgresql() {
    header "Installing PostgreSQL..."
    
    if is_postgresql_installed; then
        success "PostgreSQL is already installed"
        return 0
    fi

    show_progress "Installing PostgreSQL and contrib packages"
    
    # Install PostgreSQL from Ubuntu repositories
    if ! sudo nala install -y postgresql postgresql-contrib postgresql-client; then
        error "Failed to install PostgreSQL"
        return 1
    fi

    # Start and enable PostgreSQL service
    show_progress "Starting and enabling PostgreSQL service"
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    
    success "PostgreSQL installed successfully"
    return 0
}

# Setup PostgreSQL user and sample database
setup_postgresql() {
    header "Setting up PostgreSQL user and sample database..."
    
    # Check if PostgreSQL service is running
    if ! sudo systemctl is-active --quiet postgresql; then
        show_progress "Starting PostgreSQL service"
        sudo systemctl start postgresql
    fi
    
    # Create user if it doesn't exist
    show_progress "Creating database user '$DB_USER'"
    if sudo -u postgres psql -c "\du" | grep -q "$DB_USER"; then
        warn "User '$DB_USER' already exists, skipping creation"
    else
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' CREATEDB SUPERUSER;"
        success "Database user '$DB_USER' created successfully"
    fi
    
    # Create sample test database for connection testing
    show_progress "Creating sample test database '$SAMPLE_DB_NAME'"
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$SAMPLE_DB_NAME"; then
        warn "Sample database '$SAMPLE_DB_NAME' already exists, skipping creation"
    else
        sudo -u postgres psql -c "CREATE DATABASE $SAMPLE_DB_NAME OWNER $DB_USER;"
        success "Sample test database '$SAMPLE_DB_NAME' created successfully"
    fi
    
    return 0
}

# Configure PostgreSQL authentication
configure_postgresql() {
    header "Configuring PostgreSQL authentication..."
    
    # Find PostgreSQL version and config directory
    local pg_version
    pg_version=$(sudo -u postgres psql -c "SHOW server_version;" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    
    if [[ -z "$pg_version" ]]; then
        pg_version=$(ls /etc/postgresql/ | head -1)
    fi
    
    local pg_config_dir="/etc/postgresql/$pg_version/main"
    local pg_hba_conf="$pg_config_dir/pg_hba.conf"
    
    if [[ ! -f "$pg_hba_conf" ]]; then
        warn "Could not find pg_hba.conf at $pg_hba_conf"
        warn "You may need to manually configure PostgreSQL authentication"
        return 0
    fi
    
    show_progress "Configuring pg_hba.conf for user authentication"
    
    # Backup original pg_hba.conf
    sudo cp "$pg_hba_conf" "$pg_hba_conf.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Add or update authentication line for our user
    local auth_line="host    all             $DB_USER        127.0.0.1/32            scram-sha-256"
    
    if grep -q "host.*all.*$DB_USER.*127.0.0.1" "$pg_hba_conf"; then
        warn "Authentication line for $DB_USER already exists in pg_hba.conf"
    else
        # Add the line before the last line (which is usually local connections)
        sudo sed -i "/# IPv4 local connections:/a $auth_line" "$pg_hba_conf"
        success "Added authentication configuration for user '$DB_USER'"
    fi
    
    # Restart PostgreSQL to apply changes
    show_progress "Restarting PostgreSQL to apply configuration changes"
    sudo systemctl restart postgresql
    
    success "PostgreSQL authentication configured successfully"
    return 0
}

# Test sample database and offer to drop it
test_sample_database() {
    header "Testing sample database..."
    
    show_progress "Testing connection to sample database '$SAMPLE_DB_NAME'"
    
    # Test basic connection and create a simple test table
    if PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h 127.0.0.1 -d "$SAMPLE_DB_NAME" -c "CREATE TABLE test_table (id SERIAL PRIMARY KEY, test_message TEXT); INSERT INTO test_table (test_message) VALUES ('Database connection successful!'); SELECT * FROM test_table; DROP TABLE test_table;" >/dev/null 2>&1; then
        success "Sample database test completed successfully"
    else
        error "Failed to test sample database"
        return 1
    fi
    
    echo
    read -p "Would you like to drop the sample test database '$SAMPLE_DB_NAME'? (y/N): " drop_sample
    
    case $drop_sample in
        [Yy]|[Yy][Ee][Ss])
            show_progress "Dropping sample database '$SAMPLE_DB_NAME'"
            if sudo -u postgres psql -c "DROP DATABASE $SAMPLE_DB_NAME;"; then
                success "Sample database '$SAMPLE_DB_NAME' dropped successfully"
            else
                warn "Failed to drop sample database, you can remove it manually later"
            fi
            ;;
        *)
            info "Keeping sample database '$SAMPLE_DB_NAME' for your use"
            ;;
    esac
    
    return 0
}

# Test PostgreSQL connection
test_postgresql_connection() {
    header "Testing PostgreSQL connection..."
    
    show_progress "Testing connection to PostgreSQL as user '$DB_USER'"
    
    # Test connection to sample database
    if PGPASSWORD="$DB_PASSWORD" psql -U "$DB_USER" -h 127.0.0.1 -d "$SAMPLE_DB_NAME" -c "SELECT 'Connection successful!' as test_result;" >/dev/null 2>&1; then
        success "Connection to PostgreSQL successful"
    else
        error "Failed to connect to PostgreSQL"
        return 1
    fi
    
    return 0
}

# Install DBeaver Community Edition using Flatpak
install_dbeaver() {
    header "Installing DBeaver Community Edition..."
    
    if is_dbeaver_installed; then
        success "DBeaver is already installed"
        return 0
    fi

    # Check if flatpak is available
    if ! command -v flatpak >/dev/null 2>&1; then
        error "Flatpak is not installed. Please run 'Essential Packages' module first."
        return 1
    fi
    
    # Check if Flathub is configured
    if ! flatpak remotes | grep -q flathub; then
        error "Flathub repository is not configured. Please run 'Essential Packages' module first."
        return 1
    fi
    
    # Install DBeaver via Flatpak
    show_progress "Installing DBeaver Community Edition via Flatpak"
    if ! flatpak install -y flathub io.dbeaver.DBeaverCommunity; then
        error "Failed to install DBeaver via Flatpak"
        return 1
    fi
    
    success "DBeaver Community Edition installed successfully via Flatpak"
    return 0
}

# Add useful PostgreSQL aliases
add_postgresql_aliases() {
    header "Adding PostgreSQL aliases..."
    
    local shell_rc=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi
    
    # Check if aliases already exist
    if grep -q "# PostgreSQL aliases" "$shell_rc" 2>/dev/null; then
        warn "PostgreSQL aliases already exist in $shell_rc"
        return 0
    fi
    
    show_progress "Adding PostgreSQL aliases to $shell_rc"
    
    cat >> "$shell_rc" << EOF

# PostgreSQL aliases
alias pg-start="sudo systemctl start postgresql"
alias pg-stop="sudo systemctl stop postgresql"
alias pg-restart="sudo systemctl restart postgresql"
alias pg-status="sudo systemctl status postgresql"
alias pg-logs="sudo tail -f /var/log/postgresql/postgresql-*-main.log"
alias psql-postgres="PGPASSWORD='$DB_PASSWORD' psql -U $DB_USER -h 127.0.0.1 -d postgres"
EOF

    # Add sample database alias only if it still exists
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$SAMPLE_DB_NAME" 2>/dev/null; then
        cat >> "$shell_rc" << EOF
alias psql-sample="PGPASSWORD='$DB_PASSWORD' psql -U $DB_USER -h 127.0.0.1 -d $SAMPLE_DB_NAME"
EOF
    fi

    success "PostgreSQL aliases added to $shell_rc"
    info "Restart your terminal or run 'source $shell_rc' to use the new aliases"
    return 0
}

# Show connection information
show_connection_info() {
    header "Database Connection Information"
    
    echo
    echo "PostgreSQL Connection Details:"
    echo "  Host: localhost (127.0.0.1)"
    echo "  Port: 5432"
    echo "  Username: $DB_USER"
    echo "  Password: $DB_PASSWORD"
    echo
    echo "Available Features:"
    echo "  ✅ PostgreSQL server running"
    echo "  ✅ User '$DB_USER' with database creation privileges"
    
    # Check if sample database still exists
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$SAMPLE_DB_NAME" 2>/dev/null; then
        echo "  📊 Sample Database: $SAMPLE_DB_NAME (for testing)"
        echo
        echo "Sample Database Connection:"
        echo "  PGPASSWORD='$DB_PASSWORD' psql -U $DB_USER -h 127.0.0.1 -d $SAMPLE_DB_NAME"
    fi
    
    echo
    echo "Create New Databases:"
    echo "  PGPASSWORD='$DB_PASSWORD' psql -U $DB_USER -h 127.0.0.1 -d postgres -c \"CREATE DATABASE your_db_name;\""
    echo "  Then connect: PGPASSWORD='$DB_PASSWORD' psql -U $DB_USER -h 127.0.0.1 -d your_db_name"
    
    echo
    echo "Useful Aliases (restart terminal to use):"
    echo "  pg-start    - Start PostgreSQL service"
    echo "  pg-stop     - Stop PostgreSQL service" 
    echo "  pg-restart  - Restart PostgreSQL service"
    echo "  pg-status   - Check PostgreSQL status"
    echo "  pg-logs     - View PostgreSQL logs"
    
    if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$SAMPLE_DB_NAME" 2>/dev/null; then
        echo "  psql-sample - Connect to sample database"
    fi
    
    echo
    echo "DBeaver Connection:"
    echo "  Launch DBeaver from applications menu or run: flatpak run io.dbeaver.DBeaverCommunity"
    echo "  Create a new PostgreSQL connection with the above details"
    echo
}

# Main function
main() {
    header "Database Tools Setup"
    info "This module will install and configure database tools for development:"
    echo
    echo "📊 Database Tools to Install:"
    echo "   • PostgreSQL - Open-source relational database server"
    echo "   • DBeaver Community Edition - Universal database management tool (via Flatpak)"
    echo
    echo "🔧 Setup Process:"
    echo "   • Install PostgreSQL server and client tools"
    echo "   • Create database user with your credentials"
    echo "   • Configure authentication for local connections"
    echo "   • Create sample test database (optional to keep)"
    echo "   • Install DBeaver via Flatpak for database management"
    echo "   • Add useful PostgreSQL aliases to your shell"
    echo
    warn "Prerequisites: Run 'Essential Packages' module first for Flatpak support"
    echo
    
    if ! confirm "Do you want to install and configure database tools?"; then
        warn "Database tools installation cancelled by user"
        return 0
    fi
    
    # Get database credentials from user
    if ! get_database_credentials; then
        error "Failed to get database credentials"
        return 1
    fi
    
    # Install PostgreSQL
    if ! install_postgresql; then
        error "PostgreSQL installation failed"
        return 1
    fi
    
    # Setup PostgreSQL user and databases
    if ! setup_postgresql; then
        error "PostgreSQL setup failed"
        return 1
    fi
    
    # Configure PostgreSQL authentication
    if ! configure_postgresql; then
        error "PostgreSQL configuration failed"
        return 1
    fi
    
    # Test sample database
    if ! test_sample_database; then
        warn "Sample database test had issues, but continuing..."
    fi
    
    # Test PostgreSQL connection
    if ! test_postgresql_connection; then
        error "PostgreSQL connection test failed"
        return 1
    fi
    
    # Install DBeaver
    if ! install_dbeaver; then
        error "DBeaver installation failed"
        return 1
    fi
    
    # Add PostgreSQL aliases
    if ! add_postgresql_aliases; then
        warn "Failed to add PostgreSQL aliases, but continuing..."
    fi
    
    # Show connection information
    show_connection_info
    
    success "Database tools setup completed successfully!"
    info "You can now use DBeaver to connect to your PostgreSQL databases"
    
    return 0
}

# Run main function
main "$@"