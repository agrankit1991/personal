#!/bin/bash

# Editors and IDEs Module
# Install development editors and integrated development environments

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Install Visual Studio Code
install_vscode() {
    simple_header "Visual Studio Code Installation"
    
    if ! confirm "Do you want to install Visual Studio Code?"; then
        warn "Skipping Visual Studio Code installation"
        return 0
    fi
    
    # Check if VS Code is already installed
    if command_exists code; then
        info "Visual Studio Code is already installed"
        echo "  • Version: $(code --version | head -n 1)"
        
        if confirm "Do you want to reinstall or update VS Code?"; then
            info "Proceeding with installation to update..."
        else
            return 0
        fi
    fi
    
    show_progress "Installing Visual Studio Code from Microsoft repository"
    
    # Add Microsoft GPG key
    if wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg; then
        sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f /tmp/packages.microsoft.gpg
        
        # Update package list and install
        sudo apt update
        if sudo nala install -y code; then
            show_success "Visual Studio Code installed successfully"
            
            # Show version info
            info "VS Code installation details:"
            echo "  • Version: $(code --version | head -n 1)"
            echo "  • Installation path: $(which code)"
            
            # Install popular extensions
            if confirm "Do you want to install popular VS Code extensions?"; then
                install_vscode_extensions
            fi
            
        else
            show_error "Failed to install Visual Studio Code"
            return 1
        fi
    else
        show_error "Failed to add Microsoft GPG key"
        return 1
    fi
}

# Install popular VS Code extensions
install_vscode_extensions() {
    show_progress "Installing popular VS Code extensions"
    
    # List of popular extensions
    local extensions=(
        "ms-python.python"                    # Python support
        "ms-vscode.vscode-typescript-next"    # TypeScript support
        "ms-vscode.vscode-json"               # JSON support
        "redhat.vscode-yaml"                  # YAML support
        "ms-vscode.vscode-eslint"             # ESLint
        "esbenp.prettier-vscode"              # Prettier formatter
        "ms-vscode.vscode-git-graph"          # Git Graph
        "eamodio.gitlens"                     # GitLens
        "ms-vsliveshare.vsliveshare"          # Live Share
        "ms-vscode-remote.remote-ssh"         # Remote SSH
        "bradlc.vscode-tailwindcss"           # Tailwind CSS
        "ms-vscode.vscode-docker"             # Docker support
        "hashicorp.terraform"                 # Terraform
        "ms-kubernetes-tools.vscode-kubernetes-tools" # Kubernetes
    )
    
    echo "Popular VS Code Extensions:"
    for i in "${!extensions[@]}"; do
        local ext="${extensions[$i]}"
        local name=$(echo "$ext" | cut -d'.' -f2- | tr '-' ' ')
        echo "$((i+1)). $name ($ext)"
    done
    echo "$((${#extensions[@]}+1)). Install all recommended extensions"
    echo "$((${#extensions[@]}+2)). Skip extension installation"
    echo
    
    while true; do
        read -p "Select extensions to install (1-$((${#extensions[@]}+2))): " choice
        
        if [[ "$choice" -eq "$((${#extensions[@]}+2))" ]]; then
            info "Skipping extension installation"
            return 0
        elif [[ "$choice" -eq "$((${#extensions[@]}+1))" ]]; then
            # Install all extensions
            for ext in "${extensions[@]}"; do
                info "Installing $ext..."
                code --install-extension "$ext" --force
            done
            show_success "All recommended extensions installed"
            return 0
        elif [[ "$choice" -ge 1 && "$choice" -le "${#extensions[@]}" ]]; then
            local selected_ext="${extensions[$((choice-1))]}"
            info "Installing $selected_ext..."
            if code --install-extension "$selected_ext" --force; then
                echo "  ✅ $selected_ext installed successfully"
            else
                echo "  ⚠️  Failed to install $selected_ext"
            fi
            
            if confirm "Install another extension?"; then
                continue
            else
                return 0
            fi
        else
            error "Invalid option. Please select a number between 1 and $((${#extensions[@]}+2))."
            continue
        fi
    done
}

# Install Cursor (AI-powered code editor)
install_cursor() {
    simple_header "Cursor AI Code Editor Installation"
    
    if ! confirm "Do you want to install Cursor (AI-powered code editor)?"; then
        warn "Skipping Cursor installation"
        return 0
    fi
    
    # Check if Cursor is already installed
    if command_exists cursor; then
        info "Cursor is already installed"
        echo "  • Version: $(cursor --version 2>/dev/null || echo 'Unknown')"
        
        if confirm "Do you want to reinstall or update Cursor?"; then
            info "Proceeding with installation to update..."
        else
            return 0
        fi
    fi
    
    echo "Cursor installation methods:"
    echo "1. Download and install .deb package (recommended)"
    echo "2. Download AppImage"
    echo "3. Skip Cursor installation"
    echo
    
    while true; do
        read -p "Choose installation method (1-3): " cursor_method
        
        case "$cursor_method" in
            1)
                install_cursor_deb
                return $?
                ;;
            2)
                install_cursor_appimage
                return $?
                ;;
            3)
                info "Skipping Cursor installation"
                return 0
                ;;
            *)
                error "Invalid option. Please choose 1, 2, or 3."
                continue
                ;;
        esac
    done
}

# Install Cursor via .deb package
install_cursor_deb() {
    show_progress "Installing Cursor via .deb package"
    
    local temp_dir="/tmp/cursor-install"
    local download_url="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/1.6"
    
    mkdir -p "$temp_dir"
    
    # Download Cursor .deb package
    show_progress "Downloading Cursor .deb package from official API"
    if wget -O "$temp_dir/cursor.deb" "$download_url"; then
        show_progress "Installing Cursor package"
        
        if sudo dpkg -i "$temp_dir/cursor.deb" 2>/dev/null || sudo nala install -f -y; then
            show_success "Cursor installed successfully"
            
            # Clean up
            rm -rf "$temp_dir"
            
            info "Cursor installation details:"
            echo "  • Installation method: .deb package (official API)"
            echo "  • Launch command: cursor"
            
            return 0
        else
            show_error "Failed to install Cursor .deb package"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        show_error "Failed to download Cursor .deb package"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Install Cursor AppImage
install_cursor_appimage() {
    show_progress "Installing Cursor AppImage"
    
    local install_dir="$HOME/.local/bin"
    local appimage_url="https://api2.cursor.sh/updates/download/golden/linux-x64-appimage/cursor/1.6"
    
    mkdir -p "$install_dir"
    
    # Download Cursor AppImage
    show_progress "Downloading Cursor AppImage from official API"
    if wget -O "$install_dir/cursor.AppImage" "$appimage_url"; then
        chmod +x "$install_dir/cursor.AppImage"
        
        # Create symlink for easy access
        ln -sf "$install_dir/cursor.AppImage" "$install_dir/cursor"
        
        show_success "Cursor AppImage installed successfully"
        
        info "Cursor installation details:"
        echo "  • Installation method: AppImage (official API)"
        echo "  • Location: $install_dir/cursor.AppImage"
        echo "  • Launch command: cursor"
        
        return 0
    else
        show_error "Failed to download Cursor AppImage"
        return 1
    fi
}

# Install Windsurf (AI-native code editor)
install_windsurf() {
    simple_header "Windsurf AI Code Editor Installation"
    
    if ! confirm "Do you want to install Windsurf (AI-native code editor by Codeium)?"; then
        warn "Skipping Windsurf installation"
        return 0
    fi
    
    # Check if Windsurf is already installed
    if command_exists windsurf; then
        info "Windsurf is already installed"
        echo "  • Version: $(windsurf --version 2>/dev/null || echo 'Unknown')"
        
        if confirm "Do you want to reinstall or update Windsurf?"; then
            info "Proceeding with installation to update..."
        else
            return 0
        fi
    fi
    
    # Install via official repository
    install_windsurf_repo
}

# Install Windsurf via official repository
install_windsurf_repo() {
    show_progress "Installing Windsurf via official repository"
    
    # Check if required packages are installed
    if ! command_exists wget || ! command_exists gpg; then
        warn "wget and gpg are required. Please install 'Essential Packages' first."
        if confirm "Do you want to install wget and gpg now?"; then
            sudo nala install -y wget gpg
        else
            error "Cannot proceed without wget and gpg"
            return 1
        fi
    fi
    
    # Step 1: Add Windsurf repository and GPG key
    show_progress "Adding Windsurf repository and GPG key"
    
    # Download and install GPG key
    if wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg; then
        sudo install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
        
        # Add repository to sources list
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
        
        # Clean up temporary GPG file
        rm -f windsurf-stable.gpg
        
        show_success "Windsurf repository added successfully"
        
        # Step 2: Install apt-transport-https (required AFTER adding repository)
        show_progress "Installing apt-transport-https"
        if ! sudo nala install -y apt-transport-https; then
            show_error "Failed to install apt-transport-https"
            return 1
        fi
        
        # Step 3: Update package list
        show_progress "Updating package list"
        if ! sudo nala update; then
            show_error "Failed to update package list"
            return 1
        fi
        
        # Step 4: Install Windsurf
        show_progress "Installing Windsurf"
        if sudo nala install -y windsurf; then
            show_success "Windsurf installed successfully"
            
            info "Windsurf installation details:"
            echo "  • Installation method: Official repository"
            echo "  • Launch command: windsurf"
            echo "  • Auto-updates: Yes (via apt)"
            
            return 0
        else
            show_error "Failed to install Windsurf from repository"
            return 1
        fi
    else
        show_error "Failed to download Windsurf GPG key"
        return 1
    fi
}

# Install IntelliJ IDEA Community Edition
install_intellij_idea() {
    simple_header "IntelliJ IDEA Community Edition Installation"
    
    if ! confirm "Do you want to install IntelliJ IDEA Community Edition?"; then
        warn "Skipping IntelliJ IDEA installation"
        return 0
    fi
    
    # Check if IntelliJ IDEA is already installed
    if command_exists idea || [[ -d "/opt/idea-IC"* ]] || [[ -d "$HOME/.local/share/JetBrains/Toolbox/apps/IDEA-C"* ]]; then
        info "IntelliJ IDEA Community Edition appears to be already installed"
        
        if confirm "Do you want to reinstall or update IntelliJ IDEA?"; then
            info "Proceeding with installation..."
        else
            return 0
        fi
    fi
    
    echo "Installation method options:"
    
    # Check if Flatpak is available
    local flatpak_available="❌"
    if command_exists flatpak; then
        flatpak_available="✅"
    fi
    
    echo "1. Install via Flatpak $flatpak_available"
    echo "2. Download and install manually ✅"
    echo "3. Skip IntelliJ IDEA installation"
    echo
    
    if [[ "$flatpak_available" == "❌" ]]; then
        info "Note: Flatpak is not installed. Manual installation recommended."
    fi
    
    while true; do
        read -p "Choose installation method (1-3): " method_choice
        
        case "$method_choice" in
            1)
                install_intellij_flatpak
                return $?
                ;;
            2)
                install_intellij_manual
                return $?
                ;;
            3)
                info "Skipping IntelliJ IDEA installation"
                return 0
                ;;
            *)
                error "Invalid option. Please choose 1, 2, or 3."
                continue
                ;;
        esac
    done
}

# Install IntelliJ IDEA via Flatpak
install_intellij_flatpak() {
    show_progress "Installing IntelliJ IDEA Community Edition via Flatpak"
    
    # Check if Flatpak is installed
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Please install Essential Packages first or choose a different method."
        return 1
    fi
    
    if flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Community; then
        show_success "IntelliJ IDEA Community Edition installed successfully via Flatpak"
        
        info "IntelliJ IDEA installation details:"
        echo "  • Installed via: Flatpak"
        echo "  • Launch command: flatpak run com.jetbrains.IntelliJ-IDEA-Community"
        echo "  • Auto-updates: Via Flatpak"
        
        return 0
    else
        show_error "Failed to install IntelliJ IDEA via Flatpak"
        return 1
    fi
}

# Install IntelliJ IDEA manually
install_intellij_manual() {
    simple_header "IntelliJ IDEA Manual Installation"
    
    info "For the best experience and latest version, please download IntelliJ IDEA Community Edition manually:"
    echo
    echo "🔗 Download URL: https://www.jetbrains.com/idea/download/?section=linux"
    echo
    echo "📋 Manual Installation Steps:"
    echo "1. Visit the URL above in your browser"
    echo "2. Download IntelliJ IDEA Community Edition (.tar.gz)"
    echo "3. Extract the downloaded file"
    echo "4. Move it to a suitable location (e.g., /opt/ or ~/Applications/)"
    echo "5. Run the idea.sh script from the bin/ directory"
    echo
    echo "💡 Recommended installation location: /opt/idea-IC/"
    echo "💡 You can create a symlink for easy access:"
    echo "   sudo ln -sf /path/to/idea/bin/idea.sh /usr/local/bin/idea"
    echo
    
    info "This approach ensures you get:"
    echo "  ✅ Latest stable version"
    echo "  ✅ Official JetBrains installation"
    echo "  ✅ Full control over installation location"
    echo "  ✅ Easy updates through JetBrains Toolbox (optional)"
    echo
    
    if confirm "Have you completed the manual installation?"; then
        info "Great! IntelliJ IDEA should now be available on your system."
        echo
        info "Quick setup tips:"
        echo "  • First launch: Run idea.sh from the bin/ directory"
        echo "  • Import settings: If you have previous IntelliJ settings"
        echo "  • Install plugins: Via File → Settings → Plugins"
        echo "  • Configure SDK: File → Project Structure → SDKs"
        echo
        return 0
    else
        info "No problem! You can install IntelliJ IDEA manually later."
        info "Remember to visit: https://www.jetbrains.com/idea/download/?section=linux"
        return 0
    fi
}

# Show editors and IDEs summary
show_editors_summary() {
    box "Editors and IDEs - Installation Summary"
    
    info "🚀 Development Editors and IDEs Installed:"
    
    # Visual Studio Code
    if command_exists code; then
        echo "  ✅ Visual Studio Code - $(code --version | head -n 1)"
        echo "    └─ Launch: code"
        
        # Count installed extensions
        local ext_count=$(code --list-extensions 2>/dev/null | wc -l)
        echo "    └─ Extensions: $ext_count installed"
    fi
    
    # Cursor
    if command_exists cursor; then
        echo "  ✅ Cursor - AI-powered code editor"
        echo "    └─ Launch: cursor"
    fi
    
    # Windsurf
    if command_exists windsurf; then
        echo "  ✅ Windsurf - AI-native code editor"
        echo "    └─ Launch: windsurf"
    fi
    
    # IntelliJ IDEA Community Edition
    if command_exists idea || [[ -d "/opt/idea-IC"* ]] || flatpak list 2>/dev/null | grep -q "com.jetbrains.IntelliJ-IDEA-Community"; then
        echo "  ✅ IntelliJ IDEA Community Edition"
        
        if command_exists idea; then
            echo "    └─ Launch: idea (Manual install)"
        elif flatpak list 2>/dev/null | grep -q "com.jetbrains.IntelliJ-IDEA-Community"; then
            echo "    └─ Launch: flatpak run com.jetbrains.IntelliJ-IDEA-Community"
        fi
    fi
    
    echo
    success "Editors and IDEs setup completed! 🎉"
    
    echo
    info "📚 Quick Start:"
    command_exists code && echo "  • Open VS Code: code ."
    command_exists code && echo "  • Install VS Code extension: code --install-extension <extension-name>"
    command_exists cursor && echo "  • Open Cursor (AI): cursor ."
    command_exists windsurf && echo "  • Open Windsurf (AI): windsurf ."
    
    if command_exists idea; then
        echo "  • Open IntelliJ IDEA: idea"
    elif flatpak list 2>/dev/null | grep -q "com.jetbrains.IntelliJ-IDEA-Community"; then
        echo "  • Open IntelliJ IDEA: flatpak run com.jetbrains.IntelliJ-IDEA-Community"
    fi
    
    echo
    info "💡 Tips:"
    echo "  • VS Code settings sync: Sign in with GitHub/Microsoft account"
    echo "  • IntelliJ IDEA: First run will guide you through initial setup"
    echo "  • Both IDEs support plugin ecosystems for extended functionality"
}

# Main execution
main() {
    box "Editors and IDEs Installation"
    
    info "This module installs development editors and integrated development environments:"
    echo
    echo "📝 Code Editors:"
    echo "   • Visual Studio Code - Lightweight, extensible code editor"
    echo "   • Cursor - AI-powered code editor (VS Code fork with built-in AI)"
    echo "   • Windsurf - AI-native code editor by Codeium"
    echo "   • Popular extensions for web development, Python, etc."
    echo
    echo "🏗️  Integrated Development Environments:"
    echo "   • IntelliJ IDEA Community Edition - Java/JVM development IDE"
    echo "   • Multiple installation options (Snap, Flatpak, Manual)"
    echo
    echo "✨ Features:"
    echo "   • Automatic desktop integration"
    echo "   • Extension/plugin management"
    echo "   • Command-line shortcuts"
    echo
    warn "Prerequisites: Internet connection for downloads"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! command_exists wget && ! command_exists curl; then
        error "wget or curl is required but not installed. Please run 'Essential Packages' module first."
        exit 1
    fi
    
    if ! confirm "Do you want to proceed with editors and IDEs installation?"; then
        warn "Editors and IDEs installation cancelled by user"
        exit 0
    fi
    
    echo
    
    # Install Visual Studio Code
    install_vscode
    
    # Install Cursor (AI-powered code editor)
    echo
    install_cursor
    
    # Install Windsurf (AI-native code editor)
    echo
    install_windsurf
    
    # Install IntelliJ IDEA Community Edition
    echo
    install_intellij_idea
    
    # Show summary
    echo
    show_editors_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi