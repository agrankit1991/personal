#!/bin/bash

# Powerlevel10k Theme Installation and Configuration Functions
# Part of Terminal Improvements Module

# Install Powerlevel10k theme
install_powerlevel10k_theme() {
    simple_header "Powerlevel10k Theme"
    
    # Check if Oh My Zsh is installed
    if [[ ! -d ~/.oh-my-zsh ]]; then
        warn "Oh My Zsh is not installed. Please install it first."
        return 1
    fi
    
    if ! confirm "Do you want to install Powerlevel10k theme?"; then
        warn "Skipping Powerlevel10k theme installation"
        return 0
    fi
    
    local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    # Install or update Powerlevel10k
    if [[ ! -d "$theme_dir" ]]; then
        show_progress "Installing Powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
        
        if [[ ! -d "$theme_dir" ]]; then
            show_error "Failed to install Powerlevel10k theme"
            return 1
        fi
        
        show_success "Powerlevel10k theme installed successfully"
    else
        info "Powerlevel10k theme is already installed"
        if confirm "Do you want to update it?"; then
            show_progress "Updating Powerlevel10k theme"
            (cd "$theme_dir" && git pull)
            show_success "Powerlevel10k theme updated"
        fi
    fi
    
    echo
    info "Powerlevel10k features:"
    echo "  ✅ Fast and responsive prompt"
    echo "  ✅ Git status integration"
    echo "  ✅ Command execution time"
    echo "  ✅ Directory truncation"
    echo "  ✅ Customizable segments"
    
    echo
    warn "After restarting your terminal, run 'p10k configure' to customize your prompt"
    echo
}

# Copy Powerlevel10k configuration
setup_powerlevel10k_config() {
    simple_header "Powerlevel10k Configuration"
    
    if [[ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
        warn "Powerlevel10k theme is not installed"
        return 1
    fi
    
    if ! confirm "Do you want to copy your existing Powerlevel10k configuration?"; then
        warn "Skipping Powerlevel10k configuration copy"
        return 0
    fi
    
    # Check if the user's p10k config exists in dotfiles
    local dotfiles_p10k="/home/bawandar/Developer/personal/dotfiles/.p10k.zsh"
    
    if [[ -f "$dotfiles_p10k" ]]; then
        show_progress "Copying Powerlevel10k configuration from dotfiles"
        
        # Backup existing p10k config if it exists
        [[ -f ~/.p10k.zsh ]] && backup_file ~/.p10k.zsh
        
        # Copy the configuration
        cp "$dotfiles_p10k" ~/.p10k.zsh
        
        show_success "Powerlevel10k configuration copied successfully"
        info "Configuration file: ~/.p10k.zsh"
    else
        warn "Powerlevel10k configuration not found in dotfiles"
        info "You can run 'p10k configure' later to set up your prompt"
    fi
    
    echo
}