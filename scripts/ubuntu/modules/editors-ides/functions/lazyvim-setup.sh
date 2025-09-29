#!/bin/bash

# ===================================================================
# LAZYVIM SETUP FUNCTIONS
# ===================================================================
# This file contains all functions needed to install and configure LazyVim.
# LazyVim is a modern Neovim configuration framework that provides:
# - Fast startup with lazy loading
# - Pre-configured plugins for development
# - Beautiful UI with themes and statusline
# - LSP support for code completion and analysis
# - File explorer, fuzzy finder, and Git integration
# ===================================================================

# ===================================================================
# DIRECTORY CONFIGURATION
# ===================================================================
# Define all Neovim-related directories for organization and cleanup
NVIM_CONFIG_DIR="$HOME/.config/nvim"        # Main configuration directory
NVIM_DATA_DIR="$HOME/.local/share/nvim"     # Plugin data and state files
NVIM_STATE_DIR="$HOME/.local/state/nvim"    # Session and state information
NVIM_CACHE_DIR="$HOME/.cache/nvim"          # Cached files for performance
NVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"   # System installation directory

# ===================================================================
# NEOVIM INSTALLATION
# ===================================================================
# Installs latest Neovim from GitHub releases using official tarball method
# This ensures LazyVim compatibility with the newest Neovim version
install_neovim() {
    show_progress "Installing latest Neovim from GitHub releases"
    
    # Check if curl is available
    if ! command_exists curl; then
        error "curl is required to download Neovim"
        info "Install curl first: sudo nala install curl"
        return 1
    fi
    
    # Create temporary directory for download
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || return 1
    
    # Download latest Neovim release
    info "📥 Downloading latest Neovim tarball..."
    if curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
        show_success "Neovim tarball downloaded successfully"
    else
        error "Failed to download Neovim tarball"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Remove existing installation if it exists
    if [[ -d "$NVIM_INSTALL_DIR" ]]; then
        info "🗑️  Removing existing Neovim installation..."
        sudo rm -rf "$NVIM_INSTALL_DIR"
    fi
    
    # Extract tarball to /opt
    info "📦 Extracting Neovim to $NVIM_INSTALL_DIR..."
    if sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; then
        show_success "Neovim extracted successfully"
    else
        error "Failed to extract Neovim tarball"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Clean up temporary files
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    # Add to PATH
    setup_neovim_path
    
    return 0
}

# ===================================================================
# PATH CONFIGURATION
# ===================================================================
# Configures shell PATH to include Neovim binary location
setup_neovim_path() {
    local nvim_path="$NVIM_INSTALL_DIR/bin"
    
    info "🛠️  Configuring PATH for Neovim..."
    
    # Check if already in PATH
    if echo "$PATH" | grep -q "$nvim_path"; then
        info "✅ Neovim path already configured"
        return 0
    fi
    
    # Determine shell configuration file
    local shell_config=""
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # Add PATH export to shell config
    info "📝 Adding Neovim to PATH in $shell_config"
    echo "" >> "$shell_config"
    echo "# Neovim PATH - Added by LazyVim setup" >> "$shell_config"
    echo "export PATH=\"\$PATH:$nvim_path\"" >> "$shell_config"
    
    # Export for current session
    export PATH="$PATH:$nvim_path"
    
    show_success "✅ Neovim added to PATH"
    info "🔄 PATH will be available in new terminal sessions"
    
    return 0
}

# ===================================================================
# NEOVIM VERSION CHECK
# ===================================================================
# Verifies Neovim installation and checks version compatibility
check_neovim_installation() {
    local nvim_cmd="$NVIM_INSTALL_DIR/bin/nvim"
    
    # Check if Neovim binary exists
    if [[ ! -f "$nvim_cmd" ]]; then
        return 1
    fi
    
    # Check if it's executable and get version
    if "$nvim_cmd" --version >/dev/null 2>&1; then
        local version
        version=$("$nvim_cmd" --version | head -1)
        success "✅ Neovim installed: $version"
        return 0
    else
        return 1
    fi
}

# ===================================================================
# NEOVIM SETUP MAIN FUNCTION
# ===================================================================
# Main function to handle Neovim installation and verification
setup_neovim() {
    info "🔍 Checking Neovim installation..."
    
    # Check if Neovim is already properly installed
    if check_neovim_installation; then
        info "Neovim is already installed and working"
        
        if confirm "Do you want to reinstall Neovim to get the latest version?"; then
            install_neovim
        fi
    else
        warn "Neovim is not installed or not working properly"
        info "LazyVim requires a recent version of Neovim for full functionality"
        
        if ! confirm "Do you want to install Neovim?"; then
            warn "Cannot proceed with LazyVim setup without Neovim"
            return 1
        fi
        
        install_neovim
    fi
    
    # Final verification
    if ! check_neovim_installation; then
        error "Neovim installation failed or is not working"
        return 1
    fi
    
    return 0
}

# ===================================================================
# BACKUP EXISTING CONFIGURATION
# ===================================================================
# Safely backs up existing Neovim configuration before LazyVim installation
backup_existing_config() {
    # Check if any Neovim directories exist
    local config_exists=false
    
    if [[ -d "$NVIM_CONFIG_DIR" ]] || [[ -d "$NVIM_DATA_DIR" ]] || [[ -d "$NVIM_STATE_DIR" ]] || [[ -d "$NVIM_CACHE_DIR" ]]; then
        config_exists=true
    fi
    
    if [[ "$config_exists" == true ]]; then
        warn "⚠️  Existing Neovim configuration detected"
        info "The following directories will be replaced:"
        
        # Show what exists
        [[ -d "$NVIM_CONFIG_DIR" ]] && echo "  • Config: $NVIM_CONFIG_DIR"
        [[ -d "$NVIM_DATA_DIR" ]] && echo "  • Data: $NVIM_DATA_DIR"
        [[ -d "$NVIM_STATE_DIR" ]] && echo "  • State: $NVIM_STATE_DIR"
        [[ -d "$NVIM_CACHE_DIR" ]] && echo "  • Cache: $NVIM_CACHE_DIR"
        echo
        
        if confirm "Do you want to backup your existing Neovim configuration?"; then
            # Create timestamped backup directory
            local backup_dir="$HOME/.config/nvim-backup-$(date +%Y%m%d_%H%M%S)"
            
            show_progress "Creating backup at $backup_dir"
            mkdir -p "$backup_dir"
            
            # Backup existing directories
            [[ -d "$NVIM_CONFIG_DIR" ]] && mv "$NVIM_CONFIG_DIR" "$backup_dir/config"
            [[ -d "$NVIM_DATA_DIR" ]] && mv "$NVIM_DATA_DIR" "$backup_dir/data"
            [[ -d "$NVIM_STATE_DIR" ]] && mv "$NVIM_STATE_DIR" "$backup_dir/state"
            [[ -d "$NVIM_CACHE_DIR" ]] && mv "$NVIM_CACHE_DIR" "$backup_dir/cache"
            
            show_success "✅ Backup created at $backup_dir"
            info "To restore: mv $backup_dir/config $NVIM_CONFIG_DIR"
        else
            warn "⚠️  Proceeding without backup - existing config will be overwritten"
            
            # Remove existing directories with verbose output
            show_progress "Removing existing Neovim configuration"
            
            if [[ -d "$NVIM_CONFIG_DIR" ]]; then
                info "Removing $NVIM_CONFIG_DIR"
                rm -rf "$NVIM_CONFIG_DIR" || warn "Failed to remove config directory"
            fi
            
            if [[ -d "$NVIM_DATA_DIR" ]]; then
                info "Removing $NVIM_DATA_DIR"  
                rm -rf "$NVIM_DATA_DIR" || warn "Failed to remove data directory"
            fi
            
            if [[ -d "$NVIM_STATE_DIR" ]]; then
                info "Removing $NVIM_STATE_DIR"
                rm -rf "$NVIM_STATE_DIR" || warn "Failed to remove state directory"
            fi
            
            if [[ -d "$NVIM_CACHE_DIR" ]]; then
                info "Removing $NVIM_CACHE_DIR"
                rm -rf "$NVIM_CACHE_DIR" || warn "Failed to remove cache directory"
            fi
            
            show_success "Existing configuration removed"
        fi
    else
        info "✅ No existing Neovim configuration found - fresh installation"
    fi
}

# ===================================================================
# LAZYVIM INSTALLATION
# ===================================================================
# Installs LazyVim starter template following official installation guide
install_lazyvim_config() {
    show_progress "Installing LazyVim configuration"
    
    # Check for git
    if ! command_exists git; then
        error "git is required to install LazyVim"
        info "Installing git automatically..."
        
        if ! sudo nala install -y git; then
            error "Failed to install git"
            info "Please install git manually: sudo nala install git"
            return 1
        fi
        
        show_success "Git installed successfully"
    fi
    
    # Check for required dependencies
    info "📋 Checking required dependencies..."
    local missing_deps=()
    
    command_exists git || missing_deps+=("git")
    command_exists make || missing_deps+=("make")
    command_exists unzip || missing_deps+=("unzip")
    command_exists gcc || missing_deps+=("gcc")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warn "⚠️  Missing required dependencies: ${missing_deps[*]}"
        info "Installing dependencies..."
        
        if ! sudo nala install -y "${missing_deps[@]}"; then
            error "Failed to install required dependencies"
            return 1
        fi
    fi
    
    # Ensure the config directory is clean
    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
        warn "Configuration directory still exists: $NVIM_CONFIG_DIR"
        info "Attempting to remove it completely..."
        rm -rf "$NVIM_CONFIG_DIR"
        
        if [[ -d "$NVIM_CONFIG_DIR" ]]; then
            error "Failed to remove existing configuration directory"
            info "Please manually remove: rm -rf $NVIM_CONFIG_DIR"
            return 1
        fi
    fi
    
    # Clone LazyVim starter
    info "📥 Cloning LazyVim starter template..."
    if git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"; then
        show_success "✅ LazyVim starter cloned successfully"
    else
        error "❌ Failed to clone LazyVim starter"
        info "Possible causes:"
        echo "  • Network connectivity issues"
        echo "  • Git not installed or not working"
        echo "  • Directory permission issues"
        echo "  • Existing directory blocking installation"
        
        # Show directory status for debugging
        if [[ -d "$NVIM_CONFIG_DIR" ]]; then
            info "Directory exists: $NVIM_CONFIG_DIR"
            ls -la "$NVIM_CONFIG_DIR" 2>/dev/null || true
        fi
        
        return 1
    fi
    
    # Remove .git directory to make it user's own config
    show_progress "Preparing configuration for customization"
    rm -rf "$NVIM_CONFIG_DIR/.git"
    
    show_success "✅ LazyVim configuration installed"
    info "📁 Configuration location: $NVIM_CONFIG_DIR"
    
    return 0
}

# ===================================================================
# PLUGIN INSTALLATION
# ===================================================================
# Runs initial plugin installation using Neovim's headless mode
install_lazyvim_plugins() {
    show_progress "Installing LazyVim plugins"
    
    info "🔄 Starting plugin installation (this may take a few minutes)..."
    info "📦 Installing: LSP servers, Treesitter parsers, and essential plugins"
    
    # Use the installed Neovim to setup plugins
    local nvim_cmd="$NVIM_INSTALL_DIR/bin/nvim"
    
    # Run plugin installation in headless mode
    if "$nvim_cmd" --headless "+Lazy! sync" +qa; then
        show_success "🎉 LazyVim plugins installed successfully"
    else
        warn "⚠️  Plugin installation completed with some issues"
        info "� Some plugins may need manual installation via :Lazy sync"
    fi
    
    return 0
}

# ===================================================================
# LAZYVIM INFORMATION
# ===================================================================
# Shows helpful information about using LazyVim
show_lazyvim_info() {
    box "LazyVim Setup Complete! 🎉"
    
    # Show version info
    local nvim_version
    nvim_version=$("$NVIM_INSTALL_DIR/bin/nvim" --version | head -1)
    success "🚀 $nvim_version with LazyVim is ready!"
    
    echo
    info "🎯 Getting Started:"
    echo "  • Launch Neovim: nvim"
    echo "  • Leader key: <Space> (press space to see available commands)"
    echo "  • Help: Press <Space> then ? for help"
    echo "  • File explorer: <Space>e"
    echo "  • Find files: <Space><Space> or <Space>ff"
    echo "  • Live grep: <Space>sg"
    echo "  • Recent files: <Space>fr"
    
    echo
    info "⚙️  Plugin Management:"
    echo "  • Plugin manager: :Lazy"
    echo "  • LSP installer: :Mason"
    echo "  • Update plugins: :Lazy sync"
    echo "  • Health check: :checkhealth"
    
    echo
    info "📁 Configuration Files:"
    echo "  • Main config: ~/.config/nvim/"
    echo "  • Options: ~/.config/nvim/lua/config/options.lua"
    echo "  • Keymaps: ~/.config/nvim/lua/config/keymaps.lua"
    echo "  • Plugins: ~/.config/nvim/lua/plugins/"
    
    echo
    info "🔧 Useful Commands:"
    echo "  • :LazyExtras - Browse additional plugin sets"
    echo "  • :Mason - Install language servers and formatters"
    echo "  • :checkhealth - Diagnose configuration issues"
    echo "  • :Telescope - Access all Telescope pickers"
    
    echo
    warn "💡 Notes:"
    echo "  • First startup may be slower as plugins compile"
    echo "  • Restart your terminal to ensure PATH is updated"
    echo "  • Visit https://www.lazyvim.org/ for documentation"
    
    return 0
}

# ===================================================================
# MAIN LAZYVIM INSTALLATION FUNCTION
# ===================================================================
# Orchestrates the complete LazyVim installation process
install_lazyvim_setup() {
    simple_header "LazyVim Installation"
    
    info "🚀 LazyVim is a modern Neovim configuration that provides:"
    echo "  • ⚡ Fast startup with lazy loading"
    echo "  • 🎨 Beautiful UI with modern themes"
    echo "  • 🔍 Powerful fuzzy finding with Telescope"
    echo "  • 🌳 File explorer with Neo-tree"
    echo "  • 🧠 LSP support for intelligent coding"
    echo "  • 🔧 Git integration and terminal"
    echo "  • � Plugin ecosystem with Lazy.nvim"
    
    echo
    warn "📋 Requirements:"
    echo "  • Latest Neovim (will be installed automatically)"
    echo "  • Git, Make, Unzip, GCC (will be installed if missing)"
    echo "  • Internet connection for downloading plugins"
    
    echo
    if ! confirm "Do you want to install LazyVim with latest Neovim?"; then
        warn "LazyVim installation cancelled"
        return 0
    fi
    
    # Step 1: Install/setup Neovim
    info "🔧 Step 1: Setting up Neovim..."
    if ! setup_neovim; then
        error "Failed to setup Neovim"
        return 1
    fi
    
    # Step 2: Backup existing config
    info "💾 Step 2: Handling existing configuration..."
    backup_existing_config
    
    # Step 3: Install LazyVim
    info "⚙️  Step 3: Installing LazyVim configuration..."
    if ! install_lazyvim_config; then
        error "❌ Failed to install LazyVim configuration"
        error "Installation cannot continue without LazyVim config"
        
        # Show debugging information
        info "🔍 Debug Information:"
        echo "  • Config directory: $NVIM_CONFIG_DIR"
        echo "  • Directory exists: $([ -d "$NVIM_CONFIG_DIR" ] && echo "Yes" || echo "No")"
        echo "  • Git available: $(command_exists git && echo "Yes" || echo "No")"
        echo "  • Network test: $(curl -s --connect-timeout 5 https://github.com >/dev/null && echo "OK" || echo "Failed")"
        
        return 1
    fi
    
    # Step 4: Install plugins
    info "📦 Step 4: Installing plugins..."
    install_lazyvim_plugins
    
    # Step 5: Show completion info
    info "✅ Step 5: Setup complete!"
    show_lazyvim_info
    
    return 0
}