#!/bin/bash

# Other Applications Module
# Install various useful applications

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Productivity apps via Flatpak
PRODUCTIVITY_APPS=(
    "org.libreoffice.LibreOffice:LibreOffice"
    "org.gnome.Calendar:GNOME Calendar"
    "org.gnome.Contacts:GNOME Contacts"
    "org.gnome.Evince:Document Viewer (Evince)"
    "org.mozilla.Thunderbird:Thunderbird Email"
)

# Communication apps via Flatpak
COMMUNICATION_APPS=(
    "com.slack.Slack:Slack"
    "com.discordapp.Discord:Discord"
    "us.zoom.Zoom:Zoom"
    "com.microsoft.Teams:Microsoft Teams"
    "org.telegram.desktop:Telegram Desktop"
)

# Media apps via Flatpak
MEDIA_APPS=(
    "org.videolan.VLC:VLC Media Player"
    "com.spotify.Client:Spotify"
    "org.audacityteam.Audacity:Audacity"
    "org.gimp.GIMP:GIMP Image Editor"
    "org.inkscape.Inkscape:Inkscape Vector Graphics"
    "org.blender.Blender:Blender 3D"
)

# Utilities via Flatpak
UTILITY_APPS=(
    "org.gnome.Calculator:GNOME Calculator"
    "org.gnome.FileRoller:Archive Manager"
    "com.github.tchx84.Flatseal:Flatseal (Flatpak Permissions)"
    "io.github.flattool.Warehouse:Warehouse (Flatpak Manager)"
)

# Install productivity apps
install_productivity_apps() {
    simple_header "Productivity Applications"
    
    info "Available productivity apps:"
    for app_info in "${PRODUCTIVITY_APPS[@]}"; do
        local display_name="${app_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for app_info in "${PRODUCTIVITY_APPS[@]}"; do
        local app_id="${app_info%%:*}"
        local display_name="${app_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install communication apps
install_communication_apps() {
    simple_header "Communication Applications"
    
    info "Available communication apps:"
    for app_info in "${COMMUNICATION_APPS[@]}"; do
        local display_name="${app_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for app_info in "${COMMUNICATION_APPS[@]}"; do
        local app_id="${app_info%%:*}"
        local display_name="${app_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install media apps
install_media_apps() {
    simple_header "Media Applications"
    
    info "Available media apps:"
    for app_info in "${MEDIA_APPS[@]}"; do
        local display_name="${app_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for app_info in "${MEDIA_APPS[@]}"; do
        local app_id="${app_info%%:*}"
        local display_name="${app_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install utility apps
install_utility_apps() {
    simple_header "Utility Applications"
    
    info "Available utility apps:"
    for app_info in "${UTILITY_APPS[@]}"; do
        local display_name="${app_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for app_info in "${UTILITY_APPS[@]}"; do
        local app_id="${app_info%%:*}"
        local display_name="${app_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install multimedia codecs
install_multimedia_codecs() {
    simple_header "Multimedia Codecs"
    
    info "Installing multimedia codecs from RPM Fusion"
    echo
    
    if ! dnf repolist | grep -q "rpmfusion-free"; then
        warn "RPM Fusion repositories are not enabled"
        warn "Please run 'System Update & RPM Fusion' module first"
        return 1
    fi
    
    if confirm "Install multimedia codecs (requires RPM Fusion)?"; then
        # Install group packages for multimedia
        show_progress "Installing multimedia codecs"
        sudo dnf group install -y Multimedia
        
        # Install additional codecs
        if confirm "Install additional codecs and plugins?"; then
            sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} \
                gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
            sudo dnf install -y lame\* --exclude=lame-devel
            sudo dnf group install -y sound-and-video
        fi
        
        show_success "Multimedia codecs installed"
    else
        warn "Skipping multimedia codecs installation"
    fi
    
    echo
}

# Install virtualization tools
install_virtualization() {
    simple_header "Virtualization Tools"
    
    if confirm "Install virtualization tools (QEMU/KVM, virt-manager)?"; then
        install_dnf_package "qemu-kvm" "QEMU KVM"
        install_dnf_package "libvirt" "Libvirt"
        install_dnf_package "virt-manager" "Virtual Machine Manager"
        install_dnf_package "virt-viewer" "Virtual Machine Viewer"
        
        if confirm "Enable and start libvirtd service?"; then
            show_progress "Starting libvirtd service"
            sudo systemctl enable --now libvirtd
            show_success "libvirtd service started"
            
            # Add user to libvirt group
            if confirm "Add current user to libvirt group?"; then
                sudo usermod -aG libvirt "$USER"
                show_success "User added to libvirt group"
                warn "Please log out and log back in for group changes to take effect"
            fi
        fi
    else
        warn "Skipping virtualization tools installation"
    fi
    
    echo
}

# Install VirtualBox
install_virtualbox() {
    simple_header "VirtualBox"
    
    if dnf_package_installed "VirtualBox"; then
        info "VirtualBox is already installed"
        return 0
    fi
    
    if confirm "Install VirtualBox?"; then
        if ! dnf repolist | grep -q "rpmfusion-free"; then
            warn "RPM Fusion repositories are not enabled"
            warn "Please run 'System Update & RPM Fusion' module first"
            return 1
        fi
        
        show_progress "Installing VirtualBox"
        sudo dnf install -y VirtualBox kernel-devel
        
        # Add user to vboxusers group
        if confirm "Add current user to vboxusers group?"; then
            sudo usermod -aG vboxusers "$USER"
            show_success "User added to vboxusers group"
            warn "Please log out and log back in for group changes to take effect"
        fi
        
        show_success "VirtualBox installed"
    else
        warn "Skipping VirtualBox installation"
    fi
    
    echo
}

main() {
    box "Other Applications Installation"
    
    info "This module installs various useful applications"
    echo
    
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Please run 'Essential Packages' module first."
        exit 1
    fi
    
    if ! confirm "Do you want to proceed with applications installation?"; then
        warn "Applications installation cancelled"
        exit 0
    fi
    
    echo
    
    # Install different categories
    if confirm "Install productivity applications?"; then
        install_productivity_apps
    fi
    
    if confirm "Install communication applications?"; then
        install_communication_apps
    fi
    
    if confirm "Install media applications?"; then
        install_media_apps
    fi
    
    if confirm "Install utility applications?"; then
        install_utility_apps
    fi
    
    # Additional installations
    install_multimedia_codecs
    install_virtualization
    install_virtualbox
    
    show_success "Applications installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
