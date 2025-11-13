#!/bin/bash

# Git Configuration Module
# Sets up Git with user information and configurations

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Configure Git user information
configure_git_user() {
    simple_header "Git User Configuration"
    
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" ]]; then
        info "Current Git name: $current_name"
    fi
    
    if [[ -n "$current_email" ]]; then
        info "Current Git email: $current_email"
    fi
    
    echo
    
    if confirm "Do you want to configure Git user information?"; then
        read -p "Enter your name: " git_name
        read -p "Enter your email: " git_email
        
        if [[ -n "$git_name" ]]; then
            git config --global user.name "$git_name"
            show_success "Git name set to: $git_name"
        fi
        
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            show_success "Git email set to: $git_email"
        fi
    else
        warn "Skipping Git user configuration"
    fi
    
    echo
}

# Configure Git settings
configure_git_settings() {
    simple_header "Git Settings Configuration"
    
    if confirm "Configure recommended Git settings?"; then
        # Default branch name
        if confirm "Set default branch name to 'main'?"; then
            git config --global init.defaultBranch main
            show_success "Default branch name set to 'main'"
        fi
        
        # Line ending handling
        if confirm "Configure line ending handling (recommended)?"; then
            git config --global core.autocrlf input
            show_success "Line ending handling configured"
        fi
        
        # Pull strategy
        if confirm "Set pull strategy to rebase (recommended)?"; then
            git config --global pull.rebase false
            show_success "Pull strategy configured"
        fi
        
        # Credential helper
        if confirm "Enable credential helper (store credentials)?"; then
            git config --global credential.helper store
            show_success "Credential helper enabled"
        fi
        
        # Color UI
        git config --global color.ui auto
        show_success "Color UI enabled"
        
        # Editor
        if command_exists vim; then
            git config --global core.editor vim
            show_success "Default editor set to vim"
        fi
    else
        warn "Skipping Git settings configuration"
    fi
    
    echo
}

# Configure Git aliases
configure_git_aliases() {
    simple_header "Git Aliases Configuration"
    
    if confirm "Configure useful Git aliases?"; then
        git config --global alias.co checkout
        git config --global alias.br branch
        git config --global alias.ci commit
        git config --global alias.st status
        git config --global alias.unstage 'reset HEAD --'
        git config --global alias.last 'log -1 HEAD'
        git config --global alias.visual 'log --graph --oneline --all'
        git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
        
        show_success "Git aliases configured"
        echo
        info "Available aliases:"
        echo "  git co    = git checkout"
        echo "  git br    = git branch"
        echo "  git ci    = git commit"
        echo "  git st    = git status"
        echo "  git unstage = git reset HEAD --"
        echo "  git last  = git log -1 HEAD"
        echo "  git visual = git log --graph --oneline --all"
        echo "  git lg    = pretty log with graph"
    else
        warn "Skipping Git aliases configuration"
    fi
    
    echo
}

# Show current Git configuration
show_git_config() {
    simple_header "Current Git Configuration"
    
    if confirm "Do you want to see your current Git configuration?"; then
        git config --global --list
    fi
    
    echo
}

main() {
    box "Git Configuration"
    
    if ! command_exists git; then
        error "Git is not installed. Please run 'Essential Packages' module first."
        exit 1
    fi
    
    info "This module will configure Git with user information and useful settings"
    echo
    
    if ! confirm "Do you want to configure Git?"; then
        warn "Git configuration cancelled"
        exit 0
    fi
    
    echo
    
    # Configure Git
    configure_git_user
    configure_git_settings
    configure_git_aliases
    show_git_config
    
    show_success "Git configuration completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
