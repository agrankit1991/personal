#!/bin/bash

# System Update & Nala Installation Module
# Updates the system and installs nala (better apt frontend)

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Update system packages
update_system() {
    log "Updating system package lists..."
    sudo apt update
    
    log "Upgrading installed packages..."
    sudo apt upgrade -y
    
    log "Removing unnecessary packages..."
    sudo apt autoremove -y
    
    log "Cleaning package cache..."
    sudo apt autoclean
    
    log "System update completed successfully!"
}

# Install nala if not already installed
install_nala() {
    if command_exists nala; then
        warn "Nala is already installed"
        nala --version
        return 0
    fi
    
    show_progress "Installing nala (better apt frontend)"
    
    # Install nala
    sudo apt install -y nala
    
    if command_exists nala; then
        show_success "Nala installed successfully!"
        info "Nala version: $(nala --version)"
        echo
        info "Nala usage examples:"
        echo "  - nala install <package>   (instead of apt install)"
        echo "  - nala update              (instead of apt update)"
        echo "  - nala upgrade             (instead of apt upgrade)"
        echo "  - nala search <package>    (instead of apt search)"
        echo "  - nala show <package>      (instead of apt show)"
        echo
        info "Nala provides:"
        echo "  ✓ Better formatted output with colors"
        echo "  ✓ Parallel downloads for faster installations"
        echo "  ✓ Better dependency resolution display"
        echo "  ✓ Transaction history and rollback capabilities"
    else
        show_error "Failed to install nala"
        return 1
    fi
}

# Setup nala configuration
setup_nala_config() {
    if ! command_exists nala; then
        warn "Nala is not installed, skipping configuration"
        return 0
    fi
    
    log "Setting up nala configuration..."
    
    # Fetch fastest mirrors for better performance
    log "Fetching fastest mirrors for nala..."
    sudo nala fetch --auto -y
    
    log "Nala configuration completed!"
}

# Main execution
main() {
    box "System Update & Nala Installation"
    echo
    
    info "This module will:"
    echo "  1. Update system package lists"
    echo "  2. Upgrade all installed packages"
    echo "  3. Remove unnecessary packages and clean cache"
    echo "  4. Install nala (better apt frontend with parallel downloads)"
    echo "  5. Configure nala with fastest mirrors"
    echo
    
    if ! confirm "Do you want to continue?"; then
        warn "System update and nala installation cancelled by user"
        exit 0
    fi
    
    # Execute the steps
    update_system
    echo
    install_nala
    echo
    setup_nala_config
    echo
    
    success "🎉 System update and nala installation completed successfully!"
    echo
    info "Next steps:"
    echo "  - You can now use 'nala' instead of 'apt' for package management"
    echo "  - Try 'nala list --upgradable' to see available upgrades"
    echo "  - Use 'nala history' to see installation history"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi