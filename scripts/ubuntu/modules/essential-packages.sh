#!/bin/bash

# Essential Packages Installation Module
# Installs truly essential system and development packages using nala

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Essential packages only - no editors, IDEs, or specialized tools
SYSTEM_ESSENTIALS=(
    "curl"              # HTTP client
    "wget"              # Download utility
    "gpg"               # GNU Privacy Guard (command)
    "gnupg"             # GNU Privacy Guard (full package)
    "git"               # Version control
    "btop"              # Better system monitor
    "tree"              # Directory listing
    "lsb-release"       # LSB release information
    "flatpak"           # Universal package manager
)

BUILD_ESSENTIALS=(
    "build-essential"   # Essential compilation tools (gcc, make, etc.)
    "cmake"             # Cross-platform build system
    "pkg-config"        # Library compilation helper
)

COMPRESSION_ESSENTIALS=(
    "zip"               # ZIP archive creation/extraction
    "unzip"             # ZIP archive extraction
    "tar"               # TAR archive handling
    "rar"               # RAR archive handling
    "unrar"             # RAR archive extraction
)

MULTIMEDIA_ESSENTIALS=(
    "ffmpeg"            # Video/audio processing
    "x264"              # H.264 video codec
    "x265"              # H.265 video codec
)

FONTS_ESSENTIALS=(
    "fonts-liberation"   # Liberation fonts (Arial, Times New Roman alternatives)
    "fonts-dejavu"      # DejaVu fonts
    "fonts-noto"        # Google Noto fonts
    "ttf-mscorefonts-installer"  # Microsoft Core Fonts
)

FIREWALL_ESSENTIALS=(
    "ufw"               # Uncomplicated Firewall (CLI)
    "gufw"              # Firewall GUI
)

TEXT_PROCESSING_ESSENTIALS=(
    "jq"                # JSON processor
)



# Install fastfetch with PPA
install_fastfetch() {
    if command_exists fastfetch; then
        warn "Fastfetch is already installed"
        return 0
    fi
    
    show_progress "Installing Fastfetch"
    
    # Add PPA repository
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    
    # Update package list
    sudo nala update
    
    # Install fastfetch
    sudo nala install -y fastfetch
    
    if command_exists fastfetch; then
        show_success "Fastfetch installed successfully"
        info "Try running 'fastfetch' to see system information"
    else
        show_error "Failed to install fastfetch"
        return 1
    fi
}

# Setup Flatpak and Flathub repository
setup_flatpak() {
    if ! command_exists flatpak; then
        warn "Flatpak should have been installed with system essentials"
        return 1
    fi
    
    show_progress "Setting up Flathub repository"
    
    # Add Flathub repository
    if ! flatpak remotes | grep -q flathub; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        show_success "Flathub repository added"
        info "Flatpak is ready for use. You may need to restart your session for GUI integration."
    else
        info "Flathub repository is already configured"
    fi
}

# Install package group
install_package_group() {
    local group_name="$1"
    local -n packages=$2  # Name reference to array
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        warn "No packages defined for $group_name"
        return 0
    fi
    
    simple_header "$group_name"
    
    info "Packages to install:"
    for pkg in "${packages[@]}"; do
        # Check if package is already installed
        if package_installed "$pkg"; then
            echo "  ✅ $pkg (already installed)"
        else
            echo "  📦 $pkg"
        fi
    done
    echo
    
    if ! confirm "Install $group_name packages?"; then
        warn "Skipping $group_name installation"
        return 0
    fi
    
    show_progress "Installing $group_name packages"
    
    # Install packages with nala
    if sudo nala install -y "${packages[@]}"; then
        show_success "$group_name packages installed successfully"
    else
        show_error "Failed to install some $group_name packages"
        return 1
    fi
    
    echo
}



# Update package database
update_packages() {
    show_progress "Updating package database"
    sudo nala update
    show_success "Package database updated"
}

# Show installation summary
show_summary() {
    box "Installation Summary"
    
    info "Essential tools installed:"
    command_exists curl && echo "  ✅ cURL"
    command_exists wget && echo "  ✅ Wget"
    command_exists git && echo "  ✅ Git"
    command_exists btop && echo "  ✅ Btop"
    command_exists tree && echo "  ✅ Tree"
    command_exists cmake && echo "  ✅ CMake"
    command_exists jq && echo "  ✅ JQ"
    command_exists flatpak && echo "  ✅ Flatpak"
    command_exists fastfetch && echo "  ✅ Fastfetch"
    command_exists ffmpeg && echo "  ✅ FFmpeg"
    command_exists gufw && echo "  ✅ Firewall GUI (GUFW)"
    [[ -f /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf ]] && echo "  ✅ Liberation Fonts"
    
    echo
    success "Essential packages installation completed! 🎉"
    
    echo
    info "Next steps:"
    echo "  - Configure Git: 'git config --global user.name \"Your Name\"'"
    echo "  - Configure Git: 'git config --global user.email \"your.email@example.com\"'"
    echo "  - Configure firewall with 'sudo ufw enable' or use the GUI 'gufw'"
    echo "  - Try 'fastfetch' to see system information"
    echo "  - Install additional tools using other modules (editors, languages, etc.)"
    echo "  - Use 'nala install <package>' for additional packages"
}

# Main execution
main() {
    box "Install Essential Packages"
    
    info "This module installs truly essential system and development packages:"
    echo
    echo "📦 System Essentials:"
    echo "   • curl, wget - Download utilities"
    echo "   • git - Version control system"
    echo "   • btop, tree - System monitoring and file navigation"
    echo "   • flatpak - Universal package manager with Flathub setup"
    echo "   • fastfetch - System information display (with PPA)"
    echo
    echo "🔧 Build Essentials:"
    echo "   • build-essential - GCC, Make, and essential build tools"
    echo "   • cmake, pkg-config - Build system tools"
    echo
    echo "📁 Compression Essentials:"
    echo "   • zip/unzip, tar - Basic archive handling"
    echo "   • rar/unrar - RAR archive support"
    echo
    echo "🎬 Multimedia Essentials:"
    echo "   • ffmpeg - Video/audio processing"
    echo "   • x264, x265 - Essential video codecs (H.264/H.265)"
    echo
    echo "🔤 Font Essentials:"
    echo "   • Liberation, DejaVu, Noto fonts - Better font support"
    echo "   • Microsoft Core Fonts - Web compatibility"
    echo
    echo "🔥 Firewall Essentials:"
    echo "   • ufw - Uncomplicated Firewall (CLI)"
    echo "   • gufw - Firewall GUI"
    echo
    echo "📄 Text Processing:"
    echo "   • jq - JSON processing"
    echo
    warn "Note: Editors, IDEs, and specialized development tools are in separate modules"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! confirm "Do you want to continue with essential packages installation?"; then
        warn "Essential packages installation cancelled by user"
        exit 0
    fi
    
    # Update package database first
    update_packages
    echo
    
    # Install essential package groups
    install_package_group "System Essentials" SYSTEM_ESSENTIALS
    install_package_group "Build Essentials" BUILD_ESSENTIALS
    install_package_group "Compression Essentials" COMPRESSION_ESSENTIALS
    install_package_group "Multimedia Essentials" MULTIMEDIA_ESSENTIALS
    install_package_group "Font Essentials" FONTS_ESSENTIALS
    install_package_group "Firewall Essentials" FIREWALL_ESSENTIALS
    install_package_group "Text Processing Essentials" TEXT_PROCESSING_ESSENTIALS
    
    # Install fastfetch with PPA and setup Flatpak
    echo
    simple_header "Special Installations"
    install_fastfetch
    
    echo
    setup_flatpak
    
    show_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi