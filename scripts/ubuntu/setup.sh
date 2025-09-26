#!/bin/bash

# Ubuntu Setup Script
# A modular setup system for Ubuntu development environment

set -e  # Exit on any error

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
LIB_DIR="$SCRIPT_DIR/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Check if running as root
check_root() {
    if is_root; then
        error "This script should not be run as root. Please run as a regular user."
        exit 1
    fi
}

# Check if module exists
check_module() {
    local module="$1"
    if [[ ! -f "$MODULES_DIR/$module.sh" ]]; then
        error "Module '$module' not found in $MODULES_DIR"
        return 1
    fi
    return 0
}

# Execute module
run_module() {
    local module="$1"
    local description="$2"
    
    show_progress "Starting: $description"
    
    if check_module "$module"; then
        chmod +x "$MODULES_DIR/$module.sh"
        if bash "$MODULES_DIR/$module.sh"; then
            show_success "Completed: $description"
        else
            show_error "Failed: $description"
            return 1
        fi
    else
        return 1
    fi
}

# Show menu
show_menu() {
    clear
    box "Ubuntu Setup Script - Modular Development Environment Setup"
    echo
    echo "Available setup options:"
    echo
    echo " 1.  System Update & Nala Installation"
    echo " 2.  Install Essential Packages"
    echo " 3.  Setup Git Configuration"
    echo " 4.  Setup Terminal Improvements"
    echo " 5.  Install Browsers"
    echo " 6.  Install Development Languages"
    echo " 7.  Install Editors and IDEs"
    echo " 8.  Install Database Tools"
    echo " 9.  Install Other Applications"
    echo " 10. System Cleanup"
    echo " 11. Exit"
    echo
    echo -e "${WARNING}Note: Each option runs independently. You can run multiple options.${NC}"
    echo
}

# Main function
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Please select an option (1-11): " choice
        echo
        
        case $choice in
            1)
                run_module "system-update" "System Update & Nala Installation"
                ;;
            2)
                run_module "essential-packages" "Install Essential Packages"
                ;;
            3)
                run_module "git-config" "Setup Git Configuration"
                ;;
            4)
                run_module "terminal-improvements" "Setup Terminal Improvements"
                ;;
            5)
                run_module "browsers" "Install Browsers"
                ;;
            6)
                run_module "dev-languages" "Install Development Languages"
                ;;
            7)
                run_module "editors-ides" "Install Editors and IDEs"
                ;;
            8)
                run_module "database-tools" "Install Database Tools"
                ;;
            9)
                run_module "other-apps" "Install Other Applications"
                ;;
            10)
                run_module "system-cleanup" "System Cleanup"
                ;;
            11)
                log "Exiting setup script. Goodbye!"
                exit 0
                ;;
            *)
                error "Invalid option. Please select a number between 1 and 11."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"