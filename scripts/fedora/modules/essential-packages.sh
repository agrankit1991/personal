#!/bin/bash

# Essential Packages Installation Module
# Installs essential system and development packages

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Essential packages categories
SYSTEM_ESSENTIALS=(
    "curl:HTTP client"
    "wget:Download utility"
    "git:Version control system"
    "btop:Better system monitor"
    "tree:Directory listing tool"
    "flatpak:Universal package manager"
)

BUILD_ESSENTIALS=(
    "gcc:C compiler"
    "gcc-c++:C++ compiler"
    "make:Build automation tool"
    "cmake:Cross-platform build system"
    "automake:Tool for generating Makefiles"
    "pkg-config:Library compilation helper"
)

COMPRESSION_TOOLS=(
    "zip:ZIP archive creation"
    "unzip:ZIP archive extraction"
    "tar:TAR archive handling"
    "bzip2:BZ2 compression"
    "xz:XZ compression"
    "p7zip:7-Zip compression"
    "p7zip-plugins:7-Zip plugins"
)

MULTIMEDIA_TOOLS=(
    "ffmpeg:Video/audio processing"
)

TEXT_PROCESSING=(
    "jq:JSON processor"
    "vim-enhanced:Enhanced Vi editor"
)

NETWORK_TOOLS=(
    "net-tools:Network utilities"
    "bind-utils:DNS utilities (dig, nslookup)"
    "telnet:Telnet client"
)

# Install package category
install_category() {
    local category_name="$1"
    shift
    local packages=("$@")
    
    simple_header "$category_name"
    
    for pkg_info in "${packages[@]}"; do
        local pkg_name="${pkg_info%%:*}"
        local pkg_desc="${pkg_info##*:}"
        
        if dnf_package_installed "$pkg_name"; then
            info "$pkg_desc ($pkg_name) is already installed"
        else
            install_dnf_package "$pkg_name" "$pkg_desc"
        fi
    done
    
    echo
}

# Install fastfetch
install_fastfetch() {
    simple_header "Fastfetch Installation"
    
    if command_exists fastfetch; then
        info "Fastfetch is already installed"
        return 0
    fi
    
    if confirm "Install Fastfetch (system information tool)?"; then
        show_progress "Installing Fastfetch"
        if sudo dnf install -y fastfetch; then
            show_success "Fastfetch installed successfully"
            info "Try running 'fastfetch' to see system information"
        else
            show_error "Failed to install fastfetch"
        fi
    else
        warn "Skipping Fastfetch installation"
    fi
    
    echo
}

# Setup Flatpak and Flathub
setup_flatpak_repo() {
    simple_header "Flatpak Setup"
    
    if ! command_exists flatpak; then
        warn "Flatpak should have been installed with system essentials"
        return 1
    fi
    
    setup_flathub
    echo
}

# Install firewall tools
install_firewall() {
    simple_header "Firewall Tools"
    
    info "Fedora comes with firewalld by default"
    
    if dnf_package_installed "firewalld"; then
        info "firewalld is already installed"
        
        if confirm "Do you want to enable and start firewalld?"; then
            show_progress "Enabling firewalld"
            sudo systemctl enable --now firewalld
            show_success "firewalld enabled and started"
        fi
    else
        install_dnf_package "firewalld" "Firewall daemon"
    fi
    
    echo
}

main() {
    box "Essential Packages Installation"
    
    info "This module installs essential system and development packages"
    echo
    warn "Each package will ask for confirmation before installation"
    echo
    
    if ! confirm "Do you want to proceed with essential packages installation?"; then
        warn "Essential packages installation cancelled"
        exit 0
    fi
    
    echo
    
    # Install package categories
    install_category "System Essentials" "${SYSTEM_ESSENTIALS[@]}"
    install_category "Build Tools" "${BUILD_ESSENTIALS[@]}"
    install_category "Compression Tools" "${COMPRESSION_TOOLS[@]}"
    install_category "Multimedia Tools" "${MULTIMEDIA_TOOLS[@]}"
    install_category "Text Processing" "${TEXT_PROCESSING[@]}"
    install_category "Network Tools" "${NETWORK_TOOLS[@]}"
    
    # Install additional tools
    install_fastfetch
    install_firewall
    
    # Setup Flatpak
    setup_flatpak_repo
    
    show_success "Essential packages installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
