#!/bin/bash

# Other Applications Module
# Install useful applications and utilities that don't fit in other categories

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
            error "Flathub repository is required for some applications"
            return 1
        fi
    fi
    
    return 0
}

# Install VLC Media Player
install_vlc() {
    simple_header "VLC Media Player"
    
    if ! confirm "Do you want to install VLC Media Player via Flatpak?"; then
        warn "Skipping VLC Media Player installation"
        return 0
    fi
    
    # Check if VLC is already installed
    if flatpak list | grep -q "org.videolan.VLC"; then
        info "VLC Media Player is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing VLC Media Player via Flatpak"
    if flatpak install -y flathub org.videolan.VLC; then
        show_success "VLC Media Player installed successfully"
        info "Launch with: flatpak run org.videolan.VLC"
    else
        show_error "Failed to install VLC Media Player"
        return 1
    fi
}

# Install Discord
install_discord() {
    simple_header "Discord"
    
    if ! confirm "Do you want to install Discord via Flatpak?"; then
        warn "Skipping Discord installation"
        return 0
    fi
    
    # Check if Discord is already installed
    if flatpak list | grep -q "com.discordapp.Discord"; then
        info "Discord is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Discord via Flatpak"
    if flatpak install -y flathub com.discordapp.Discord; then
        show_success "Discord installed successfully"
        info "Launch with: flatpak run com.discordapp.Discord"
    else
        show_error "Failed to install Discord"
        return 1
    fi
}

# Install Slack
install_slack() {
    simple_header "Slack"
    
    if ! confirm "Do you want to install Slack via Flatpak?"; then
        warn "Skipping Slack installation"
        return 0
    fi
    
    # Check if Slack is already installed
    if flatpak list | grep -q "com.slack.Slack"; then
        info "Slack is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Slack via Flatpak"
    if flatpak install -y flathub com.slack.Slack; then
        show_success "Slack installed successfully"
        info "Launch with: flatpak run com.slack.Slack"
    else
        show_error "Failed to install Slack"
        return 1
    fi
}

# Install LibreOffice
install_libreoffice() {
    simple_header "LibreOffice"
    
    if ! confirm "Do you want to install LibreOffice via Flatpak?"; then
        warn "Skipping LibreOffice installation"
        return 0
    fi
    
    # Check if LibreOffice is already installed
    if flatpak list | grep -q "org.libreoffice.LibreOffice"; then
        info "LibreOffice is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing LibreOffice via Flatpak"
    if flatpak install -y flathub org.libreoffice.LibreOffice; then
        show_success "LibreOffice installed successfully"
        info "Launch with: flatpak run org.libreoffice.LibreOffice"
    else
        show_error "Failed to install LibreOffice"
        return 1
    fi
}

# Install GIMP
install_gimp() {
    simple_header "GIMP (GNU Image Manipulation Program)"
    
    if ! confirm "Do you want to install GIMP via Flatpak?"; then
        warn "Skipping GIMP installation"
        return 0
    fi
    
    # Check if GIMP is already installed
    if flatpak list | grep -q "org.gimp.GIMP"; then
        info "GIMP is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing GIMP via Flatpak"
    if flatpak install -y flathub org.gimp.GIMP; then
        show_success "GIMP installed successfully"
        info "Launch with: flatpak run org.gimp.GIMP"
    else
        show_error "Failed to install GIMP"
        return 1
    fi
}

# Install OBS Studio
install_obs() {
    simple_header "OBS Studio"
    
    if ! confirm "Do you want to install OBS Studio via Flatpak?"; then
        warn "Skipping OBS Studio installation"
        return 0
    fi
    
    # Check if OBS Studio is already installed
    if flatpak list | grep -q "com.obsproject.Studio"; then
        info "OBS Studio is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing OBS Studio via Flatpak"
    if flatpak install -y flathub com.obsproject.Studio; then
        show_success "OBS Studio installed successfully"
        info "Launch with: flatpak run com.obsproject.Studio"
    else
        show_error "Failed to install OBS Studio"
        return 1
    fi
}

# Install Postman
install_postman() {
    simple_header "Postman"
    
    if ! confirm "Do you want to install Postman via Flatpak?"; then
        warn "Skipping Postman installation"
        return 0
    fi
    
    # Check if Postman is already installed
    if flatpak list | grep -q "com.getpostman.Postman"; then
        info "Postman is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Postman via Flatpak"
    if flatpak install -y flathub com.getpostman.Postman; then
        show_success "Postman installed successfully"
        info "Launch with: flatpak run com.getpostman.Postman"
    else
        show_error "Failed to install Postman"
        return 1
    fi
}

# Install Spotify
install_spotify() {
    simple_header "Spotify"
    
    if ! confirm "Do you want to install Spotify via Flatpak?"; then
        warn "Skipping Spotify installation"
        return 0
    fi
    
    # Check if Spotify is already installed
    if flatpak list | grep -q "com.spotify.Client"; then
        info "Spotify is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Spotify via Flatpak"
    if flatpak install -y flathub com.spotify.Client; then
        show_success "Spotify installed successfully"
        info "Launch with: flatpak run com.spotify.Client"
    else
        show_error "Failed to install Spotify"
        return 1
    fi
}

# Install Transmission BitTorrent Client
install_transmission() {
    simple_header "Transmission BitTorrent Client"
    
    if ! confirm "Do you want to install Transmission via Flatpak?"; then
        warn "Skipping Transmission installation"
        return 0
    fi
    
    # Check if Transmission is already installed
    if flatpak list | grep -q "com.transmissionbt.Transmission"; then
        info "Transmission is already installed via Flatpak"
        return 0
    fi
    
    show_progress "Installing Transmission via Flatpak"
    if flatpak install -y flathub com.transmissionbt.Transmission; then
        show_success "Transmission installed successfully"
        info "Launch with: flatpak run com.transmissionbt.Transmission"
    else
        show_error "Failed to install Transmission"
        return 1
    fi
}



# Show installation summary
show_summary() {
    box "Other Applications Installation Summary"
    
    info "Installed applications:"
    
    # Check Flatpak applications
    flatpak list | grep -q "org.videolan.VLC" && echo "  ✅ VLC Media Player"
    flatpak list | grep -q "com.discordapp.Discord" && echo "  ✅ Discord"
    flatpak list | grep -q "com.slack.Slack" && echo "  ✅ Slack"
    flatpak list | grep -q "org.libreoffice.LibreOffice" && echo "  ✅ LibreOffice"
    flatpak list | grep -q "org.gimp.GIMP" && echo "  ✅ GIMP"
    flatpak list | grep -q "com.obsproject.Studio" && echo "  ✅ OBS Studio"
    flatpak list | grep -q "com.getpostman.Postman" && echo "  ✅ Postman"
    flatpak list | grep -q "com.spotify.Client" && echo "  ✅ Spotify"
    flatpak list | grep -q "com.transmissionbt.Transmission" && echo "  ✅ Transmission"
    

    
    echo
    success "Other applications installation completed! 🎉"
    
    echo
    info "Usage tips:"
    echo "  • Launch Flatpak apps from the application menu or use 'flatpak run <app-id>'"
    echo "  • Most applications will appear in your desktop application menu"
    echo "  • Use 'flatpak list' to see all installed Flatpak applications"
}

# Main function
main() {
    header "Other Applications Setup"
    info "This module installs useful applications and utilities that don't fit in other categories:"
    echo
    echo "🎬 Media & Entertainment:"
    echo "   • VLC Media Player - Universal media player"
    echo "   • Spotify - Music streaming"
    echo "   • OBS Studio - Screen recording and streaming"
    echo
    echo "💬 Communication:"
    echo "   • Discord - Gaming and community chat"
    echo "   • Slack - Business communication"
    echo
    echo "📄 Productivity:"
    echo "   • LibreOffice - Office suite (Writer, Calc, Impress)"
    echo "   • GIMP - Image editing"
    echo "   • Postman - API development and testing"
    echo
    echo " File Management:"
    echo "   • Transmission - BitTorrent client"
    echo
    warn "Prerequisites: Run 'Essential Packages' module first for Flatpak support"
    echo
    
    if ! confirm "Do you want to install other applications?"; then
        warn "Other applications installation cancelled by user"
        return 0
    fi
    
    # Check prerequisites
    if ! check_flatpak; then
        error "Flatpak is not properly configured"
        return 1
    fi
    
    # Install applications
    install_vlc
    install_discord
    install_slack
    install_libreoffice
    install_gimp
    install_obs
    install_postman
    install_spotify
    install_transmission
    
    # Show summary
    show_summary
    
    success "Other applications setup completed successfully!"
    info "All applications are ready to use from your application menu or terminal"
    
    return 0
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi