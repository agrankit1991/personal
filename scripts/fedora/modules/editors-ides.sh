#!/bin/bash

# Editors and IDEs Module
# Install text editors and IDEs

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Editors/IDEs available via Flatpak
EDITORS_FLATPAK=(
    "com.visualstudio.code:Visual Studio Code"
    "com.vscodium.codium:VSCodium (Open Source VS Code)"
    "org.gnome.TextEditor:GNOME Text Editor"
    "org.kde.kate:Kate Text Editor"
    "com.sublimetext.three:Sublime Text"
)

IDES_FLATPAK=(
    "com.jetbrains.IntelliJ-IDEA-Community:IntelliJ IDEA Community"
    "com.jetbrains.PyCharm-Community:PyCharm Community"
    "org.eclipse.Java:Eclipse IDE"
    "io.atom.Atom:Atom Editor"
)

# Install terminal-based editors
install_terminal_editors() {
    simple_header "Terminal-Based Editors"
    
    # Vim
    if is_app_installed "vim"; then
        info "Vim is already installed"
    else
        install_dnf_package "vim-enhanced" "Vim (enhanced)"
    fi
    
    # Neovim
    if is_app_installed "nvim"; then
        info "Neovim is already installed"
    else
        install_dnf_package "neovim" "Neovim"
    fi
    
    # Emacs
    if confirm "Install Emacs?"; then
        install_dnf_package "emacs" "Emacs"
    fi
    
    # Nano (usually pre-installed)
    if ! command_exists nano; then
        install_dnf_package "nano" "Nano"
    else
        info "Nano is already installed"
    fi
    
    echo
}

# Install GUI editors via Flatpak
install_gui_editors() {
    simple_header "GUI Text Editors (Flatpak)"
    
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Skipping GUI editors."
        return 1
    fi
    
    info "Available GUI editors:"
    for editor_info in "${EDITORS_FLATPAK[@]}"; do
        local display_name="${editor_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for editor_info in "${EDITORS_FLATPAK[@]}"; do
        local app_id="${editor_info%%:*}"
        local display_name="${editor_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install IDEs via Flatpak
install_ides() {
    simple_header "IDEs (Flatpak)"
    
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Skipping IDEs."
        return 1
    fi
    
    info "Available IDEs:"
    for ide_info in "${IDES_FLATPAK[@]}"; do
        local display_name="${ide_info##*:}"
        echo "  • $display_name"
    done
    echo
    
    for ide_info in "${IDES_FLATPAK[@]}"; do
        local app_id="${ide_info%%:*}"
        local display_name="${ide_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            info "$display_name is already installed"
        else
            install_flatpak_app "$app_id" "$display_name"
        fi
    done
    
    echo
}

# Install Android Studio
install_android_studio() {
    simple_header "Android Studio"
    
    if flatpak_app_installed "com.google.AndroidStudio"; then
        info "Android Studio is already installed"
        return 0
    fi
    
    install_flatpak_app "com.google.AndroidStudio" "Android Studio"
    
    echo
}

# Install JetBrains Toolbox
install_jetbrains_toolbox() {
    simple_header "JetBrains Toolbox"
    
    if flatpak_app_installed "com.jetbrains.Toolbox"; then
        info "JetBrains Toolbox is already installed"
        return 0
    fi
    
    if confirm "Install JetBrains Toolbox (manage all JetBrains IDEs)?"; then
        install_flatpak_app "com.jetbrains.Toolbox" "JetBrains Toolbox"
    else
        warn "Skipping JetBrains Toolbox"
    fi
    
    echo
}

# Configure Neovim (optional)
configure_neovim() {
    simple_header "Neovim Configuration"
    
    if ! command_exists nvim; then
        warn "Neovim is not installed"
        return 0
    fi
    
    if [[ -d "$HOME/.config/nvim" ]]; then
        info "Neovim configuration already exists"
        if ! confirm "Install LazyVim (Neovim distribution)?"; then
            return 0
        fi
    fi
    
    if confirm "Install LazyVim (modern Neovim configuration)?"; then
        show_progress "Installing LazyVim"
        
        # Backup existing config
        if [[ -d "$HOME/.config/nvim" ]]; then
            backup_file "$HOME/.config/nvim"
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Clone LazyVim starter
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
        
        show_success "LazyVim installed"
        info "Run 'nvim' to complete the installation"
    else
        warn "Skipping LazyVim installation"
    fi
    
    echo
}

# Show installed editors
list_installed_editors() {
    simple_header "Installed Editors and IDEs"
    
    echo "Terminal Editors:"
    local terminal_editors=("vim" "nvim" "emacs" "nano")
    for editor in "${terminal_editors[@]}"; do
        if command_exists "$editor"; then
            echo "  ✅ $editor"
        fi
    done
    
    echo
    echo "GUI Editors and IDEs (Flatpak):"
    
    for editor_info in "${EDITORS_FLATPAK[@]}" "${IDES_FLATPAK[@]}"; do
        local app_id="${editor_info%%:*}"
        local display_name="${editor_info##*:}"
        
        if flatpak_app_installed "$app_id"; then
            echo "  ✅ $display_name"
        fi
    done
    
    echo
}

main() {
    box "Editors and IDEs Installation"
    
    info "This module installs text editors and IDEs"
    echo
    
    if ! confirm "Do you want to proceed with editors/IDEs installation?"; then
        warn "Editors/IDEs installation cancelled"
        exit 0
    fi
    
    echo
    
    # Install different categories
    if confirm "Install terminal-based editors?"; then
        install_terminal_editors
    fi
    
    if confirm "Install GUI text editors?"; then
        install_gui_editors
    fi
    
    if confirm "Install IDEs?"; then
        install_ides
    fi
    
    # Special installations
    install_android_studio
    install_jetbrains_toolbox
    
    # Configure Neovim
    configure_neovim
    
    # Show installed
    list_installed_editors
    
    show_success "Editors and IDEs installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
