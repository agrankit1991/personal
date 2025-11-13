#!/bin/bash

# Terminal Improvements Module - Main Entry Point
# Installs modern CLI tools, Oh My Zsh, and terminal enhancements

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"
FUNCTIONS_DIR="$SCRIPT_DIR/terminal-improvements/functions"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Source modular functions
source "$FUNCTIONS_DIR/cli-tools.sh"
source "$FUNCTIONS_DIR/oh-my-zsh.sh"
source "$FUNCTIONS_DIR/powerlevel10k.sh"
source "$FUNCTIONS_DIR/zsh-config.sh"

# Modern CLI tools
CLI_TOOLS=(
    "ripgrep:Better grep (rg command)"
    "fd-find:Better find (fd command)"
    "bat:Better cat with syntax highlighting"
    "eza:Better ls with colors and icons"
    "zoxide:Smart cd that learns habits"
    "duf:Better df for disk usage"
    "ncdu:Interactive disk usage analyzer"
    "fzf:Fuzzy finder"
    "tldr:Simplified man pages"
    "htop:Interactive process viewer"
)

# Configure Zsh as default shell
set_zsh_default() {
    simple_header "Set Zsh as Default Shell"
    
    if ! command_exists zsh; then
        warn "Zsh is not installed"
        return 0
    fi
    
    local current_shell=$(basename "$SHELL")
    
    if [[ "$current_shell" == "zsh" ]]; then
        info "Zsh is already your default shell"
        return 0
    fi
    
    if confirm "Set Zsh as your default shell?"; then
        show_progress "Changing default shell to Zsh"
        chsh -s "$(which zsh)"
        show_success "Default shell changed to Zsh"
        warn "Please log out and log back in for the change to take effect"
    else
        warn "Keeping current shell: $current_shell"
    fi
    
    echo
}

main() {
    box "Terminal Improvements"
    
    info "This module installs modern CLI tools and terminal enhancements"
    echo
    
    if ! confirm "Do you want to install terminal improvements?"; then
        warn "Terminal improvements installation cancelled"
        exit 0
    fi
    
    echo
    
    # Install CLI tools
    install_cli_tools
    
    # Install Oh My Zsh
    install_oh_my_zsh
    
    # Install plugins
    install_oh_my_zsh_plugins
    
    # Install Powerlevel10k
    install_powerlevel10k_theme
    
    # Setup modular Zsh configuration
    setup_modular_zsh_config
    
    # Copy Powerlevel10k configuration
    setup_powerlevel10k_config
    
    # Set Zsh as default
    set_zsh_default
    
    # Show tips
    show_terminal_tips
    
    show_success "Terminal improvements installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
