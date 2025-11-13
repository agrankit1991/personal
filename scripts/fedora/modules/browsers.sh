#!/bin/bash

# Browsers Module
# Install and manage browsers using Flatpak

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Browser definitions (Flatpak ID:Display Name)
BROWSERS=(
    "org.mozilla.firefox:Firefox"
    "com.google.Chrome:Google Chrome"
    "com.brave.Browser:Brave"
    "org.chromium.Chromium:Chromium"
    "com.opera.Opera:Opera"
    "com.vivaldi.Vivaldi:Vivaldi"
    "com.microsoft.Edge:Microsoft Edge"
)

# Check if Flatpak is ready
check_flatpak() {
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Please run 'Essential Packages' module first."
        return 1
    fi
    
    if ! flatpak remotes | grep -q flathub; then
        warn "Flathub repository is not configured"
        if confirm "Do you want to add Flathub repository now?"; then
            setup_flathub
        else
            error "Flathub repository is required for browser installation"
            return 1
        fi
    fi
    
    return 0
}

# List installed browsers
list_installed_browsers() {
    simple_header "Installed Browsers"
    
    echo "Checking for installed browsers..."
    echo
    
    local browsers_found=false
    
    # Check DNF packages
    info "DNF-installed browsers:"
    local dnf_browsers=("firefox" "chromium" "google-chrome-stable" "opera-stable")
    
    for browser in "${dnf_browsers[@]}"; do
        if dnf_package_installed "$browser"; then
            echo "  ✅ $browser (DNF package)"
            browsers_found=true
        fi
    done
    
    # Check Flatpak packages
    if command_exists flatpak; then
        info "Flatpak-installed browsers:"
        
        for browser_info in "${BROWSERS[@]}"; do
            local app_id="${browser_info%%:*}"
            local display_name="${browser_info##*:}"
            
            if flatpak_app_installed "$app_id"; then
                echo "  ✅ $display_name (Flatpak: $app_id)"
                browsers_found=true
            fi
        done
    fi
    
    if ! $browsers_found; then
        warn "No browsers found"
    fi
    
    echo
}

# Install browsers
install_browsers() {
    simple_header "Browser Installation"
    
    info "Available browsers to install via Flatpak:"
    echo
    
    for browser_info in "${BROWSERS[@]}"; do
        local app_id="${browser_info%%:*}"
        local display_name="${browser_info##*:}"
        
        echo "  • $display_name"
    done
    
    echo
    
    for browser_info in "${BROWSERS[@]}"; do
        local app_id="${browser_info%%:*}"
        local display_name="${browser_info##*:}"
        
        install_flatpak_app "$app_id" "$display_name"
    done
}

# Remove browsers
remove_browsers() {
    simple_header "Remove Browsers"
    
    if ! confirm "Do you want to remove browsers?"; then
        warn "Skipping browser removal"
        return 0
    fi
    
    echo
    
    # Remove DNF browsers
    local dnf_browsers=("firefox" "chromium" "google-chrome-stable")
    
    for browser in "${dnf_browsers[@]}"; do
        if dnf_package_installed "$browser"; then
            if confirm "Remove $browser (DNF package)?"; then
                show_progress "Removing $browser"
                if sudo dnf remove -y "$browser"; then
                    show_success "$browser removed successfully"
                else
                    show_error "Failed to remove $browser"
                fi
            fi
        fi
    done
    
    # Remove Flatpak browsers
    if command_exists flatpak; then
        for browser_info in "${BROWSERS[@]}"; do
            local app_id="${browser_info%%:*}"
            local display_name="${browser_info##*:}"
            
            if flatpak_app_installed "$app_id"; then
                if confirm "Remove $display_name (Flatpak)?"; then
                    show_progress "Removing $display_name"
                    if flatpak uninstall -y "$app_id"; then
                        show_success "$display_name removed successfully"
                    else
                        show_error "Failed to remove $display_name"
                    fi
                fi
            fi
        done
    fi
    
    echo
}

main() {
    box "Browsers Installation"
    
    info "This module manages browser installation via Flatpak"
    echo
    
    if ! check_flatpak; then
        exit 1
    fi
    
    # List currently installed browsers
    list_installed_browsers
    
    # Install browsers
    if confirm "Do you want to install browsers?"; then
        install_browsers
    else
        warn "Skipping browser installation"
    fi
    
    echo
    
    # Remove browsers
    remove_browsers
    
    show_success "Browser module completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
