#!/bin/bash

# Zsh Configuration Functions
# Part of Terminal Improvements Module

# Setup modular Zsh configuration
setup_modular_zsh_config() {
    simple_header "Modular Zsh Configuration"
    
    if ! confirm "Do you want to setup a modular Zsh configuration?"; then
        warn "Skipping modular Zsh configuration"
        return 0
    fi
    
    show_progress "Setting up modular Zsh configuration"
    
    # Create .config/zsh directory for modular config
    local zsh_config_dir="$HOME/.config/zsh"
    mkdir -p "$zsh_config_dir"
    
    # Get the directory of this script to find templates
    local template_dir="$(dirname "${BASH_SOURCE[0]}")/../templates"
    
    # Backup existing .zshrc
    [[ -f ~/.zshrc ]] && backup_file ~/.zshrc
    
    # Create main .zshrc from template
    if [[ -f "$template_dir/zshrc.template" ]]; then
        cp "$template_dir/zshrc.template" ~/.zshrc
        info "Created ~/.zshrc from template"
    else
        show_error "Template file not found: $template_dir/zshrc.template"
        return 1
    fi
    
    # Create aliases file from template
    if [[ -f "$template_dir/aliases.zsh.template" ]]; then
        cp "$template_dir/aliases.zsh.template" "$zsh_config_dir/aliases.zsh"
        info "Created ~/.config/zsh/aliases.zsh from template"
    else
        show_error "Template file not found: $template_dir/aliases.zsh.template"
        return 1
    fi
    
    # Create exports file from template
    if [[ -f "$template_dir/exports.zsh.template" ]]; then
        cp "$template_dir/exports.zsh.template" "$zsh_config_dir/exports.zsh"
        info "Created ~/.config/zsh/exports.zsh from template"
    else
        show_error "Template file not found: $template_dir/exports.zsh.template"
        return 1
    fi
    
    # Create functions file from template
    if [[ -f "$template_dir/functions.zsh.template" ]]; then
        cp "$template_dir/functions.zsh.template" "$zsh_config_dir/functions.zsh"
        info "Created ~/.config/zsh/functions.zsh from template"
    else
        show_error "Template file not found: $template_dir/functions.zsh.template"
        return 1
    fi
    
    info "Created modular configuration files:"
    echo "  📁 ~/.zshrc - Main configuration"
    echo "  📁 ~/.config/zsh/aliases.zsh - Command aliases"
    echo "  📁 ~/.config/zsh/exports.zsh - Environment variables"
    echo "  📁 ~/.config/zsh/functions.zsh - Custom functions"
    
    show_success "Modular Zsh configuration created successfully"
    echo
}
