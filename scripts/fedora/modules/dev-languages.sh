#!/bin/bash

# Development Languages Module
# Install programming languages and development tools

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Install Python and tools
install_python() {
    simple_header "Python Installation"
    
    if confirm "Install Python development tools?"; then
        # Python 3
        install_dnf_package "python3" "Python 3"
        install_dnf_package "python3-pip" "Python package manager (pip)"
        install_dnf_package "python3-devel" "Python development headers"
        install_dnf_package "python3-virtualenv" "Python virtual environment"
        
        # Additional Python tools
        if confirm "Install pipx (for installing Python apps)?"; then
            install_dnf_package "pipx" "Python application installer"
        fi
        
        if confirm "Install poetry (Python dependency management)?"; then
            if ! command_exists poetry; then
                show_progress "Installing Poetry"
                curl -sSL https://install.python-poetry.org | python3 -
                show_success "Poetry installed"
                warn "Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
            else
                info "Poetry is already installed"
            fi
        fi
    else
        warn "Skipping Python installation"
    fi
    
    echo
}

# Install Node.js
install_nodejs() {
    simple_header "Node.js Installation"
    
    if command_exists node; then
        info "Node.js is already installed: $(node --version)"
        if ! confirm "Reinstall or update Node.js?"; then
            return 0
        fi
    fi
    
    if confirm "Install Node.js?"; then
        echo
        echo "Select Node.js version:"
        echo "1. Latest LTS (recommended)"
        echo "2. Latest Current"
        echo "3. Specific version via nvm"
        echo "4. Skip"
        read -p "Choice [1-4]: " node_choice
        
        case $node_choice in
            1)
                install_dnf_package "nodejs" "Node.js (LTS from DNF)"
                install_dnf_package "npm" "Node Package Manager"
                ;;
            2)
                warn "Latest Current version not available in DNF. Using LTS."
                install_dnf_package "nodejs" "Node.js"
                install_dnf_package "npm" "Node Package Manager"
                ;;
            3)
                install_nvm
                ;;
            4)
                warn "Skipping Node.js installation"
                ;;
            *)
                error "Invalid choice"
                ;;
        esac
    else
        warn "Skipping Node.js installation"
    fi
    
    echo
}

# Install NVM (Node Version Manager)
install_nvm() {
    if [[ -d "$HOME/.nvm" ]]; then
        info "NVM is already installed"
        return 0
    fi
    
    show_progress "Installing NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if command_exists nvm; then
        show_success "NVM installed successfully"
        info "Install Node.js with: nvm install --lts"
    else
        show_error "Failed to install NVM"
    fi
}

# Install Java via SDKMAN
install_java() {
    simple_header "Java Installation"
    
    if command_exists java; then
        info "Java is already installed: $(java -version 2>&1 | head -n 1)"
        if ! confirm "Install additional Java versions or SDKMAN?"; then
            return 0
        fi
    fi
    
    if confirm "Install SDKMAN (Java version manager)?"; then
        if [[ -d "$HOME/.sdkman" ]]; then
            info "SDKMAN is already installed"
        else
            show_progress "Installing SDKMAN"
            curl -s "https://get.sdkman.io" | bash
            
            # Source SDKMAN
            source "$HOME/.sdkman/bin/sdkman-init.sh"
            
            if command_exists sdk; then
                show_success "SDKMAN installed successfully"
                info "Install Java with: sdk install java"
                info "List versions with: sdk list java"
            else
                show_error "Failed to install SDKMAN"
            fi
        fi
    else
        if confirm "Install default OpenJDK from DNF?"; then
            install_dnf_package "java-latest-openjdk" "OpenJDK (latest)"
            install_dnf_package "java-latest-openjdk-devel" "OpenJDK development tools"
        fi
    fi
    
    echo
}

# Install Go
install_go() {
    simple_header "Go Installation"
    
    if command_exists go; then
        info "Go is already installed: $(go version)"
        if ! confirm "Reinstall Go?"; then
            return 0
        fi
    fi
    
    if confirm "Install Go?"; then
        install_dnf_package "golang" "Go programming language"
        
        if command_exists go; then
            info "Go installed: $(go version)"
            info "GOPATH: $HOME/go"
        fi
    else
        warn "Skipping Go installation"
    fi
    
    echo
}

# Install Rust
install_rust() {
    simple_header "Rust Installation"
    
    if command_exists rustc; then
        info "Rust is already installed: $(rustc --version)"
        if ! confirm "Update or reinstall Rust?"; then
            return 0
        fi
    fi
    
    if confirm "Install Rust?"; then
        show_progress "Installing Rust via rustup"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        
        # Source cargo env
        source "$HOME/.cargo/env"
        
        if command_exists rustc; then
            show_success "Rust installed successfully: $(rustc --version)"
            info "Cargo installed: $(cargo --version)"
        else
            show_error "Failed to install Rust"
        fi
    else
        warn "Skipping Rust installation"
    fi
    
    echo
}

# Install Docker
install_docker() {
    simple_header "Docker Installation"
    
    if command_exists docker; then
        info "Docker is already installed: $(docker --version)"
        if ! confirm "Reconfigure Docker?"; then
            return 0
        fi
    fi
    
    if confirm "Install Docker?"; then
        show_progress "Installing Docker"
        
        # Install Docker from official repository
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Start and enable Docker
        sudo systemctl enable --now docker
        
        # Add user to docker group
        if confirm "Add current user to docker group (allows running docker without sudo)?"; then
            sudo usermod -aG docker "$USER"
            show_success "User added to docker group"
            warn "Please log out and log back in for group changes to take effect"
        fi
        
        show_success "Docker installed successfully"
    else
        warn "Skipping Docker installation"
    fi
    
    echo
}

# Install other languages
install_other_languages() {
    simple_header "Other Languages"
    
    # PHP
    if confirm "Install PHP?"; then
        install_dnf_package "php" "PHP"
        install_dnf_package "php-cli" "PHP CLI"
        install_dnf_package "php-fpm" "PHP FastCGI Process Manager"
    fi
    
    # Ruby
    if confirm "Install Ruby?"; then
        install_dnf_package "ruby" "Ruby"
        install_dnf_package "ruby-devel" "Ruby development headers"
    fi
    
    # Perl
    if confirm "Install Perl?"; then
        install_dnf_package "perl" "Perl"
    fi
    
    echo
}

main() {
    box "Development Languages Installation"
    
    info "This module installs programming languages and development tools"
    echo
    
    if ! confirm "Do you want to proceed with development languages installation?"; then
        warn "Development languages installation cancelled"
        exit 0
    fi
    
    echo
    
    # Install languages
    install_python
    install_nodejs
    install_java
    install_go
    install_rust
    install_docker
    install_other_languages
    
    show_success "Development languages installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
