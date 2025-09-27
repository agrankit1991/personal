#!/bin/bash

# Oh My Zsh Installation and Configuration Functions
# Part of Terminal Improvements Module

# Install Oh My Zsh framework
install_oh_my_zsh() {
    simple_header "Oh My Zsh Installation"
    
    # Check if user is using zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        warn "You're not using Zsh as your default shell"
        if ! confirm "Do you want to install Oh My Zsh anyway? (You can change your shell later)"; then
            warn "Skipping Oh My Zsh installation"
            return 0
        fi
    fi
    
    # Check if Oh My Zsh is already installed
    if [[ -d ~/.oh-my-zsh ]]; then
        info "Oh My Zsh is already installed"
        return 0
    fi
    
    if ! confirm "Do you want to install Oh My Zsh framework?"; then
        warn "Skipping Oh My Zsh installation"
        return 0
    fi
    
    show_progress "Installing Oh My Zsh"
    
    # Backup existing .zshrc if it exists
    [[ -f ~/.zshrc ]] && backup_file ~/.zshrc
    
    # Install Oh My Zsh (non-interactive)
    RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    if [[ ! -d ~/.oh-my-zsh ]]; then
        show_error "Failed to install Oh My Zsh"
        return 1
    fi
    
    show_success "Oh My Zsh installed successfully"
    echo
}

# Install Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    simple_header "Oh My Zsh Plugins"
    
    # Check if Oh My Zsh is installed
    if [[ ! -d ~/.oh-my-zsh ]]; then
        warn "Oh My Zsh is not installed. Please install it first."
        return 1
    fi
    
    if ! confirm "Do you want to install useful Oh My Zsh plugins?"; then
        warn "Skipping Oh My Zsh plugins installation"
        return 0
    fi
    
    show_progress "Installing Oh My Zsh plugins"
    
    local plugins_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins"
    
    # Install zsh-completions
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        info "Installing zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$plugins_dir/zsh-completions"
    else
        info "Updating zsh-completions..."
        (cd "$plugins_dir/zsh-completions" && git pull)
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    else
        info "Updating zsh-syntax-highlighting..."
        (cd "$plugins_dir/zsh-syntax-highlighting" && git pull)
    fi
    
    # Install zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        info "Updating zsh-autosuggestions..."
        (cd "$plugins_dir/zsh-autosuggestions" && git pull)
    fi
    
    # Install k (directory listing with git info)
    if [[ ! -d "$plugins_dir/k" ]]; then
        info "Installing k plugin..."
        git clone https://github.com/supercrabtree/k "$plugins_dir/k"
    else
        info "Updating k plugin..."
        (cd "$plugins_dir/k" && git pull)
    fi
    
    show_success "Oh My Zsh plugins installed successfully"
    echo
}