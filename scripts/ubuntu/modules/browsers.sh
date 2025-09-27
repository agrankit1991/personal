#!/bin/bash

# Browsers Module
# Install Brave browser and manage other browsers using Flatpak

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Check if Flatpak is ready
check_flatpak() {
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Please run 'Essential Packages' module first."
        info "The Essential Packages module installs Flatpak and sets up Flathub repository."
        return 1
    fi
    
    # Check if Flathub is added
    if ! flatpak remotes | grep -q flathub; then
        warn "Flathub repository is not configured"
        if confirm "Do you want to add Flathub repository now?"; then
            show_progress "Adding Flathub repository"
            sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            show_success "Flathub repository added"
        else
            error "Flathub repository is required for browser installation"
            return 1
        fi
    fi
    
    return 0
}

# Install Brave browser
install_brave_browser() {
    simple_header "Brave Browser Installation"
    
    if ! confirm "Do you want to install Brave browser via Flatpak?"; then
        warn "Skipping Brave browser installation"
        return 0
    fi
    
    # Check if Brave is already installed
    if flatpak list | grep -q "com.brave.Browser"; then
        info "Brave browser is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Brave browser via Flatpak"
    
    if flatpak install -y flathub com.brave.Browser; then
        show_success "Brave browser installed successfully"
        info "You can launch Brave from the applications menu or run: flatpak run com.brave.Browser"
    else
        show_error "Failed to install Brave browser"
        return 1
    fi
}

# List installed browsers
list_installed_browsers() {
    simple_header "Installed Browsers"
    
    echo "Checking for installed browsers..."
    echo
    
    local browsers_found=false
    
    # Check APT packages
    info "APT-installed browsers:"
    local apt_browsers=("firefox" "chromium-browser" "google-chrome-stable" "opera-stable" "vivaldi-stable")
    
    for browser in "${apt_browsers[@]}"; do
        if package_installed "$browser"; then
            echo "  ✅ $browser (APT package)"
            browsers_found=true
        fi
    done
    
    # Check Snap packages
    if command_exists snap; then
        info "Snap-installed browsers:"
        local snap_browsers=("firefox" "chromium" "brave" "opera")
        
        for browser in "${snap_browsers[@]}"; do
            if snap list 2>/dev/null | grep -q "^$browser "; then
                echo "  ✅ $browser (Snap package)"
                browsers_found=true
            fi
        done
    fi
    
    # Check Flatpak packages
    if command_exists flatpak; then
        info "Flatpak-installed browsers:"
        local flatpak_browsers=(
            "org.mozilla.firefox:Firefox"
            "org.chromium.Chromium:Chromium" 
            "com.google.Chrome:Google Chrome"
            "com.brave.Browser:Brave"
            "com.opera.Opera:Opera"
            "com.vivaldi.Vivaldi:Vivaldi"
            "org.mozilla.Thunderbird:Thunderbird"
        )
        
        for browser_info in "${flatpak_browsers[@]}"; do
            local app_id="${browser_info%%:*}"
            local display_name="${browser_info##*:}"
            
            if flatpak list 2>/dev/null | grep -q "$app_id"; then
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

# Remove browsers
remove_browsers() {
    simple_header "Remove Browsers"
    
    if ! confirm "Do you want to remove other browsers?"; then
        warn "Skipping browser removal"
        return 0
    fi
    
    echo "Select browsers to remove:"
    echo
    
    # Remove APT browsers
    local apt_browsers=("firefox" "chromium-browser" "google-chrome-stable" "opera-stable" "vivaldi-stable")
    
    for browser in "${apt_browsers[@]}"; do
        if package_installed "$browser"; then
            if confirm "Remove $browser (APT package)?"; then
                show_progress "Removing $browser"
                if sudo nala remove -y "$browser"; then
                    show_success "$browser removed successfully"
                else
                    warn "Failed to remove $browser"
                fi
            fi
        fi
    done
    
    # Remove Snap browsers
    if command_exists snap; then
        local snap_browsers=("firefox" "chromium" "brave" "opera")
        
        for browser in "${snap_browsers[@]}"; do
            if snap list 2>/dev/null | grep -q "^$browser "; then
                if confirm "Remove $browser (Snap package)?"; then
                    show_progress "Removing $browser snap"
                    if sudo snap remove "$browser"; then
                        show_success "$browser snap removed successfully"
                    else
                        warn "Failed to remove $browser snap"
                    fi
                fi
            fi
        done
    fi
    
    # Remove Flatpak browsers (except Brave)
    if command_exists flatpak; then
        local flatpak_browsers=(
            "org.mozilla.firefox:Firefox"
            "org.chromium.Chromium:Chromium" 
            "com.google.Chrome:Google Chrome"
            "com.opera.Opera:Opera"
            "com.vivaldi.Vivaldi:Vivaldi"
        )
        
        for browser_info in "${flatpak_browsers[@]}"; do
            local app_id="${browser_info%%:*}"
            local display_name="${browser_info##*:}"
            
            if flatpak list 2>/dev/null | grep -q "$app_id"; then
                if confirm "Remove $display_name (Flatpak: $app_id)?"; then
                    show_progress "Removing $display_name"
                    if flatpak uninstall -y "$app_id"; then
                        show_success "$display_name removed successfully"
                    else
                        warn "Failed to remove $display_name"
                    fi
                fi
            fi
        done
    fi
    
    echo
    info "Browser removal completed"
}

# Install additional browsers
install_additional_browsers() {
    simple_header "Additional Browsers"
    
    if ! confirm "Do you want to install additional browsers?"; then
        warn "Skipping additional browser installation"
        return 0
    fi
    
    echo "Available browsers for installation via Flatpak:"
    echo
    echo "1. Firefox"
    echo "2. Google Chrome"  
    echo "3. Chromium"
    echo "4. Opera"
    echo "5. Vivaldi"
    echo "6. Skip additional browsers"
    echo
    
    while true; do
        read -p "Select browser to install (1-6): " browser_choice
        
        case $browser_choice in
            1)
                if confirm "Install Firefox via Flatpak?"; then
                    show_progress "Installing Firefox"
                    flatpak install -y flathub org.mozilla.firefox && show_success "Firefox installed"
                fi
                ;;
            2)
                if confirm "Install Google Chrome via Flatpak?"; then
                    show_progress "Installing Google Chrome"
                    flatpak install -y flathub com.google.Chrome && show_success "Google Chrome installed"
                fi
                ;;
            3)
                if confirm "Install Chromium via Flatpak?"; then
                    show_progress "Installing Chromium"
                    flatpak install -y flathub org.chromium.Chromium && show_success "Chromium installed"
                fi
                ;;
            4)
                if confirm "Install Opera via Flatpak?"; then
                    show_progress "Installing Opera"
                    flatpak install -y flathub com.opera.Opera && show_success "Opera installed"
                fi
                ;;
            5)
                if confirm "Install Vivaldi via Flatpak?"; then
                    show_progress "Installing Vivaldi"
                    flatpak install -y flathub com.vivaldi.Vivaldi && show_success "Vivaldi installed"
                fi
                ;;
            6)
                info "Skipping additional browser installation"
                break
                ;;
            *)
                error "Invalid option. Please select 1-6."
                continue
                ;;
        esac
        
        if confirm "Install another browser?"; then
            continue
        else
            break
        fi
    done
}

# Show browser tips
show_browser_tips() {
    box "Browser Setup - Tips & Information"
    
    info "🌐 Browser Management:"
    echo "  • Brave browser installed via Flatpak for better security isolation"
    echo "  • Flatpak browsers have sandboxed permissions"
    echo "  • You can manage Flatpak apps via GNOME Software or KDE Discover"
    
    echo
    info "🚀 Brave Browser Features:"
    echo "  • Built-in ad and tracker blocking"
    echo "  • Privacy-focused by default"
    echo "  • Chromium-based (supports Chrome extensions)"
    echo "  • Built-in Tor browsing mode"
    echo "  • Rewards system for viewing privacy-respecting ads"
    
    echo
    info "📱 Useful Commands:"
    echo "  • Launch Brave: flatpak run com.brave.Browser"
    echo "  • Update all Flatpaks: flatpak update"
    echo "  • List Flatpak apps: flatpak list"
    echo "  • Remove Flatpak app: flatpak uninstall <app-id>"
    
    echo
    success "Browser setup completed! 🎉"
    
    echo
    info "Pro tips:"
    echo "  • Set Brave as your default browser in System Settings"
    echo "  • Import bookmarks and passwords from your previous browser"
    echo "  • Enable Brave Sync to sync data across devices"
    echo "  • Explore Brave Shields settings for customized blocking"
    echo "  • Consider using Brave Search for privacy-focused web search"
}

# Main execution
main() {
    box "Browser Installation & Management"
    
    info "This module helps you:"
    echo
    echo "🦁 Install Brave Browser:"
    echo "   • Privacy-focused browser with built-in ad blocking"
    echo "   • Installed via Flatpak for better security"
    echo
    echo "🗑️  Remove Other Browsers:"
    echo "   • Clean up unwanted browsers (Firefox, Chrome, etc.)"
    echo "   • Supports APT, Snap, and Flatpak packages"
    echo
    echo "➕ Optional Additional Browsers:"
    echo "   • Install other browsers if needed"
    echo "   • All via Flatpak for consistency"
    echo
    warn "Prerequisites: Requires Flatpak (install via 'Essential Packages' module first)"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! check_flatpak; then
        exit 1
    fi
    
    if ! confirm "Do you want to proceed with browser setup?"; then
        warn "Browser setup cancelled by user"
        exit 0
    fi
    
    echo
    
    # Show current browsers
    list_installed_browsers
    
    # Install Brave browser
    install_brave_browser
    
    # Remove other browsers
    echo
    remove_browsers
    
    # Install additional browsers if needed
    echo
    install_additional_browsers
    
    # Show tips
    echo
    show_browser_tips
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi