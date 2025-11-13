#!/bin/bash

# System Update & RPM Fusion Module
# Updates system and enables RPM Fusion repositories

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

main() {
    box "System Update & RPM Fusion Setup"
    
    info "This module will:"
    echo "  • Update system packages"
    echo "  • Enable RPM Fusion repositories (optional)"
    echo "  • Clean package cache"
    echo
    
    # System update
    if confirm "Do you want to update the system?"; then
        show_progress "Updating system packages"
        sudo dnf upgrade --refresh -y
        show_success "System updated successfully"
    else
        warn "Skipping system update"
    fi
    
    echo
    
    # Enable RPM Fusion
    enable_rpmfusion
    
    echo
    
    # Update after enabling RPM Fusion
    if dnf repolist | grep -q "rpmfusion-free"; then
        if confirm "Update package cache after enabling RPM Fusion?"; then
            show_progress "Updating package cache"
            sudo dnf check-update || true  # This returns non-zero if updates available
            show_success "Package cache updated"
        fi
    fi
    
    echo
    show_success "System update module completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
