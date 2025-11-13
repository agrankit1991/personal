#!/bin/bash

# Terminal Improvements Module
# Installs modern CLI tools and terminal enhancements

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

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

# Install CLI tools
install_cli_tools() {
    simple_header "Modern CLI Tools Installation"
    
    for tool_info in "${CLI_TOOLS[@]}"; do
        local tool_name="${tool_info%%:*}"
        local tool_desc="${tool_info##*:}"
        
        if dnf_package_installed "$tool_name"; then
            info "$tool_desc is already installed"
        else
            install_dnf_package "$tool_name" "$tool_desc"
        fi
    done
    
    echo
}

# Install Oh My Zsh
install_oh_my_zsh() {
    simple_header "Oh My Zsh Installation"
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "Oh My Zsh is already installed"
        return 0
    fi
    
    if ! command_exists zsh; then
        if confirm "Zsh is not installed. Install it now?"; then
            install_dnf_package "zsh" "Z Shell"
        else
            warn "Oh My Zsh requires Zsh. Skipping."
            return 1
        fi
    fi
    
    if confirm "Install Oh My Zsh?"; then
        show_progress "Installing Oh My Zsh"
        
        # Download and install Oh My Zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            show_success "Oh My Zsh installed successfully"
        else
            show_error "Failed to install Oh My Zsh"
            return 1
        fi
    else
        warn "Skipping Oh My Zsh installation"
    fi
    
    echo
}

# Install Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    simple_header "Oh My Zsh Plugins"
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        warn "Oh My Zsh is not installed. Skipping plugins."
        return 0
    fi
    
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        if confirm "Install zsh-autosuggestions plugin?"; then
            show_progress "Installing zsh-autosuggestions"
            git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
            show_success "zsh-autosuggestions installed"
        fi
    else
        info "zsh-autosuggestions is already installed"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        if confirm "Install zsh-syntax-highlighting plugin?"; then
            show_progress "Installing zsh-syntax-highlighting"
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
            show_success "zsh-syntax-highlighting installed"
        fi
    else
        info "zsh-syntax-highlighting is already installed"
    fi
    
    echo
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    simple_header "Powerlevel10k Theme"
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        warn "Oh My Zsh is not installed. Skipping Powerlevel10k."
        return 0
    fi
    
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        info "Powerlevel10k is already installed"
        return 0
    fi
    
    if confirm "Install Powerlevel10k theme?"; then
        show_progress "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        
        if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
            show_success "Powerlevel10k installed successfully"
            info "To use Powerlevel10k, set ZSH_THEME=\"powerlevel10k/powerlevel10k\" in ~/.zshrc"
        else
            show_error "Failed to install Powerlevel10k"
            return 1
        fi
    else
        warn "Skipping Powerlevel10k installation"
    fi
    
    echo
}

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

# Show usage tips
show_usage_tips() {
    simple_header "Usage Tips"
    
    info "Modern CLI tool replacements:"
    echo "  rg <pattern>        - Search files (replaces grep)"
    echo "  fd <pattern>        - Find files (replaces find)"
    echo "  bat <file>          - View file with syntax highlighting (replaces cat)"
    echo "  eza -la             - List files with colors (replaces ls)"
    echo "  z <dir>             - Jump to directory (smart cd)"
    echo "  duf                 - View disk usage (replaces df)"
    echo "  ncdu                - Interactive disk usage"
    echo
    info "After installing Oh My Zsh:"
    echo "  Restart your terminal or run: exec zsh"
    echo "  Configure Powerlevel10k: p10k configure"
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
    install_powerlevel10k
    
    # Set Zsh as default
    set_zsh_default
    
    # Show tips
    show_usage_tips
    
    show_success "Terminal improvements installation completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
