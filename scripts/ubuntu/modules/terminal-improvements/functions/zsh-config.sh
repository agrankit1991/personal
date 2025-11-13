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
    
    # Create dev-servers file from template
    if [[ -f "$template_dir/dev-servers.zsh.template" ]]; then
        cp "$template_dir/dev-servers.zsh.template" "$zsh_config_dir/dev-servers.zsh"
        info "Created ~/.config/zsh/dev-servers.zsh from template"
    else
        show_error "Template file not found: $template_dir/dev-servers.zsh.template"
        return 1
    fi
    
    info "Created modular configuration files:"
    echo "  📁 ~/.zshrc - Main configuration"
    echo "  📁 ~/.config/zsh/aliases.zsh - Command aliases"
    echo "  📁 ~/.config/zsh/exports.zsh - Environment variables"
    echo "  📁 ~/.config/zsh/functions.zsh - Custom functions"
    echo "  📁 ~/.config/zsh/dev-servers.zsh - Development server shortcuts"
    
    show_success "Modular Zsh configuration created successfully"
    echo
}

# Setup shell aliases and functions (legacy function for compatibility)
setup_shell_aliases() {
    simple_header "Shell Aliases and Functions"
    
    if ! confirm "Do you want to setup additional shell aliases?"; then
        warn "Skipping additional shell aliases setup"
        return 0
    fi
    
    local shell_config=""
    
    # Determine shell config file
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        warn "Unsupported shell: $SHELL"
        return 0
    fi
    
    show_progress "Setting up additional shell aliases"
    
    # Backup existing config
    [[ -f "$shell_config" ]] && backup_file "$shell_config"
    
    # Add aliases section
    cat >> "$shell_config" << 'EOF'

# ===== Additional Terminal Improvements Aliases =====

# Modern CLI replacements (fallback aliases)
if command -v eza &> /dev/null; then
    alias ls='eza'
    alias ll='eza -la'
    alias la='eza -a'
    alias lt='eza --tree'
    alias l='eza -lah'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
    alias catp='bat --paging=never'  # bat without pager
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi

if command -v fd &> /dev/null; then
    alias find='fd'
fi

if command -v duf &> /dev/null; then
    alias df='duf'
fi

EOF

    # Add zoxide initialization if installed
    if command_exists zoxide; then
        if [[ "$SHELL" == *"zsh"* ]]; then
            echo 'eval "$(zoxide init zsh)"' >> "$shell_config"
        elif [[ "$SHELL" == *"bash"* ]]; then
            echo 'eval "$(zoxide init bash)"' >> "$shell_config"
        fi
        info "Added zoxide initialization to shell config"
    fi
    
    show_success "Additional shell aliases added to $shell_config"
    warn "Please restart your terminal or run 'source $shell_config' to apply changes"
    echo
}