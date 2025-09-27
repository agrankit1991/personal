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

# Modern CLI replacements available in repositories
MODERN_CLI_TOOLS=(
    "ripgrep"           # Better grep (rg command)
    "fd-find"           # Better find (fd command)
    "bat"               # Better cat with syntax highlighting
    "eza"               # Better ls with colors and icons
    "zoxide"            # Smart cd that learns your habits
    "duf"               # Better df (disk usage)
    "ncdu"              # Interactive disk usage analyzer
    "fzf"               # Fuzzy finder
    "tldr"              # Simplified man pages
    "tree"              # Directory structure viewer
    "htop"              # Interactive process viewer
)

# Main execution
main() {
    box "Terminal Improvements"
    
    info "This module installs modern CLI tools and terminal enhancements:"
    echo
    echo "🔧 Modern CLI Tools:"
    echo "   • ripgrep (rg) - Better grep with regex support"
    echo "   • fd-find (fd) - Better find command"
    echo "   • bat - Better cat with syntax highlighting"
    echo "   • eza - Better ls with colors and icons"
    echo "   • duf - Better df for disk usage"
    echo "   • ncdu - Interactive disk usage analyzer"
    echo "   • fzf - Fuzzy finder for files and commands"
    echo
    echo "🚀 Productivity Tools:"
    echo "   • zoxide (z) - Smart cd that learns your habits"
    echo "   • Oh My Zsh - Zsh framework with plugins"
    echo "   • Powerlevel10k - Beautiful and fast prompt theme"
    echo
    echo "📚 Utilities:"
    echo "   • tldr - Simplified man pages"
    echo
    warn "Note: All tools will be installed from standard repositories"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! confirm "Do you want to install terminal improvements?"; then
        warn "Terminal improvements installation cancelled by user"
        exit 0
    fi
    
    # Update package database first
    show_progress "Updating package database"
    sudo nala update
    show_success "Package database updated"
    echo
    
    # Install CLI tools from repositories
    install_cli_tools
    
    # Install Oh My Zsh framework
    echo
    install_oh_my_zsh
    
    # Install Oh My Zsh plugins
    install_oh_my_zsh_plugins
    
    # Install Powerlevel10k theme
    install_powerlevel10k_theme
    
    # Setup modular Zsh configuration
    setup_modular_zsh_config
    
    # Copy Powerlevel10k configuration
    setup_powerlevel10k_config
    
    # Show usage tips
    echo
    show_terminal_tips
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi