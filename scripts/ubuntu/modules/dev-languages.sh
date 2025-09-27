#!/bin/bash

# Development Languages Module
# Install programming languages, runtimes, and development tools

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Get popular Java versions from SDKMAN
get_popular_java_versions() {
    # Get the list of Java versions and filter for popular vendors and recent versions
    local java_list
    
    # First, try to get versions from popular vendors (including Amazon Corretto)
    java_list=$(sdk list java 2>/dev/null | grep -E "(tem|oracle|graal|ms|amzn|librca|sapmchn)" | head -15)
    
    if [[ -z "$java_list" ]]; then
        # Fallback: get all available versions, excluding headers and empty lines
        java_list=$(sdk list java 2>/dev/null | grep -v "Available Java" | grep -v "===============" | grep -v "^[[:space:]]*$" | grep -v "Vendor" | grep -v "Use" | head -15)
    fi
    
    # If still empty, try even more basic approach
    if [[ -z "$java_list" ]]; then
        java_list=$(sdk list java 2>/dev/null | tail -n +5 | head -15)
    fi
    
    echo "$java_list"
}

# Get all Java versions from SDKMAN
get_all_java_versions() {
    # Get the complete list of Java versions from SDKMAN
    local java_list
    
    # Get all available versions, excluding headers and empty lines
    java_list=$(sdk list java 2>/dev/null | grep -v "Available Java" | grep -v "===============" | grep -v "^[[:space:]]*$" | grep -v "Vendor" | grep -v "Use")
    
    # If empty, try basic approach
    if [[ -z "$java_list" ]]; then
        java_list=$(sdk list java 2>/dev/null | tail -n +5)
    fi
    
    echo "$java_list"
}

# Show Java version selection menu
show_java_version_menu() {
    local mode="${1:-popular}"  # "popular" or "all"
    local java_versions_output
    local header_text
    
    if [[ "$mode" == "popular" ]]; then
        java_versions_output=$(get_popular_java_versions)
        header_text="Popular Java versions from SDKMAN:"
    else
        java_versions_output=$(get_all_java_versions)
        header_text="All available Java versions from SDKMAN:"
    fi
    
    echo "$header_text"
    echo
    
    # Parse and display versions
    local -a versions_array
    local -a display_lines
    local i=1
    
    while IFS= read -r line; do
        # Skip empty lines, headers, and status indicators
        if [[ -n "$line" && "$line" != *"Available Java"* && "$line" != *"="* && "$line" != *"Vendor"* && "$line" != *"Use"* ]]; then
            # Clean the line and extract version identifier
            local clean_line=$(echo "$line" | sed 's/[|*>]//g' | xargs)
            
            if [[ -n "$clean_line" ]]; then
                # Extract version identifier (last field after cleaning)
                local version=$(echo "$clean_line" | awk '{print $NF}')
                
                # Validate version format (should contain version numbers or known identifiers)
                if [[ -n "$version" && "$version" != "Identifier" && "$version" =~ [0-9] ]]; then
                    versions_array+=("$version")
                    
                    # Display with vendor and version info
                    local vendor_info=$(echo "$clean_line" | awk '{for(i=1;i<NF;i++) printf "%s ", $i}')
                    
                    # Format the display nicely
                    if [[ -n "$vendor_info" ]]; then
                        display_lines+=("$i. $vendor_info -> $version")
                    else
                        display_lines+=("$i. $version")
                    fi
                    ((i++))
                fi
            fi
        fi
    done <<< "$java_versions_output"
    
    # Check if we have any versions parsed
    if [[ $i -eq 1 ]]; then
        warn "No versions were parsed successfully. Showing full SDKMAN list:"
        echo
        sdk list java
        echo
        info "Please manually install Java with: sdk install java <version>"
        info "Example: sdk install java 21.0.4-tem"
        return 0
    fi
    
    # Display versions
    for ((j=0; j<$((i-1)); j++)); do
        echo "${display_lines[$j]}"
    done
    
    echo
    echo "Additional options:"
    if [[ "$mode" == "popular" ]]; then
        echo "$i. Show all available versions"
        echo "$((i+1)). Search for specific version"
        echo "$((i+2)). Skip Java installation"
    else
        echo "$i. Back to popular versions"
        echo "$((i+1)). Search for specific version"
        echo "$((i+2)). Skip Java installation"
    fi
    echo
    
    while true; do
        if [[ "$mode" == "popular" ]]; then
            read -p "Select Java version (1-$((i-1))), or option ($i-$((i+2))): " choice
        else
            read -p "Select Java version (1-$((i-1))), or option ($i-$((i+2))): " choice
        fi
        
        if [[ "$choice" -eq "$((i+2))" ]]; then
            info "Skipping Java installation"
            return 0
        elif [[ "$choice" -eq "$((i+1))" ]]; then
            # Search functionality
            echo
            read -p "Enter search term (version number, vendor name, etc.): " search_term
            echo
            echo "Search results for '$search_term':"
            echo "-----------------------------------"
            
            local found=0
            local search_versions_output
            if [[ "$mode" == "popular" ]]; then
                search_versions_output=$(get_all_java_versions)  # Search in all versions
            else
                search_versions_output="$java_versions_output"
            fi
            
            local search_i=1
            while IFS= read -r line; do
                if [[ -n "$line" && "$line" != *"Available Java"* && "$line" != *"="* && "$line" != *"Vendor"* && "$line" != *"Use"* ]]; then
                    local clean_line=$(echo "$line" | sed 's/[|*>]//g' | xargs)
                    if [[ -n "$clean_line" && "$clean_line" == *"$search_term"* ]]; then
                        local version=$(echo "$clean_line" | awk '{print $NF}')
                        if [[ -n "$version" && "$version" != "Identifier" && "$version" =~ [0-9] ]]; then
                            local vendor_info=$(echo "$clean_line" | awk '{for(i=1;i<NF;i++) printf "%s ", $i}')
                            echo "$search_i. $vendor_info -> $version"
                            ((search_i++))
                            ((found++))
                        fi
                    fi
                fi
            done <<< "$search_versions_output"
            
            if [[ $found -eq 0 ]]; then
                echo "No versions found matching '$search_term'"
            fi
            echo
            read -p "Press Enter to continue..." dummy
            echo
            continue
        elif [[ "$choice" -eq "$i" ]]; then
            # Toggle between popular and all versions
            if [[ "$mode" == "popular" ]]; then
                echo
                show_progress "Fetching all Java versions from SDKMAN"
                show_java_version_menu "all"
                return $?
            else
                echo
                show_progress "Showing popular Java versions"
                show_java_version_menu "popular"
                return $?
            fi
        elif [[ "$choice" -ge 1 && "$choice" -le $((i-1)) ]]; then
            local selected_version="${versions_array[$((choice-1))]}"
            
            echo
            show_progress "Installing Java $selected_version"
            
            if sdk install java "$selected_version"; then
                show_success "Java $selected_version installed successfully"
                
                if confirm "Do you want to set this as the default Java version?"; then
                    sdk default java "$selected_version"
                    show_success "Set Java $selected_version as default version"
                fi
                
                # Show Java version info
                echo
                info "Java installation details:"
                java -version
                echo
                info "JAVA_HOME: $JAVA_HOME"
                
                return 0
            else
                show_error "Failed to install Java $selected_version"
                if confirm "Try another version?"; then
                    continue
                else
                    return 1
                fi
            fi
        else
            if [[ "$mode" == "popular" ]]; then
                error "Invalid option. Please select a number between 1 and $((i+2))."
            else
                error "Invalid option. Please select a number between 1 and $((i+2))."
            fi
            continue
        fi
    done
}

# Install SDKMAN
install_sdkman() {
    simple_header "SDKMAN Installation"
    
    # Check if SDKMAN is already installed
    if [[ -d "$HOME/.sdkman" ]]; then
        info "SDKMAN is already installed"
        return 0
    fi
    
    if ! confirm "Do you want to install SDKMAN (Software Development Kit Manager)?"; then
        warn "Skipping SDKMAN installation"
        return 0
    fi
    
    show_progress "Installing SDKMAN"
    
    # Install SDKMAN
    if curl -s "https://get.sdkman.io" | bash; then
        show_success "SDKMAN installed successfully"
        
        # Source SDKMAN for current session
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        info "SDKMAN has been installed and initialized"
        info "You can use 'sdk list java' to see available Java versions"
    else
        show_error "Failed to install SDKMAN"
        return 1
    fi
}

# Install Java using SDKMAN
install_java_sdkman() {
    simple_header "Java Installation via SDKMAN"
    
    # Check if SDKMAN is available
    if [[ ! -d "$HOME/.sdkman" ]]; then
        error "SDKMAN is not installed. Please install SDKMAN first."
        return 1
    fi
    
    # Source SDKMAN
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    if ! confirm "Do you want to install Java via SDKMAN?"; then
        warn "Skipping Java installation"
        return 0
    fi
    
    show_progress "Fetching popular Java versions from SDKMAN"
    
    # Get popular Java versions from SDKMAN first
    local java_versions_output
    java_versions_output=$(get_popular_java_versions)
    
    if [[ -z "$java_versions_output" ]]; then
        error "Failed to fetch Java versions from SDKMAN"
        info "Trying to run 'sdk list java' directly..."
        
        # Try direct command as fallback
        if sdk list java >/dev/null 2>&1; then
            info "SDKMAN is working. Showing full Java list:"
            sdk list java
            echo
            info "You can install any version manually with: sdk install java <version>"
            return 0
        else
            error "SDKMAN 'list java' command failed. Please check SDKMAN installation."
            return 1
        fi
    fi
    
    # First show popular versions
    show_java_version_menu "popular"

}

# Install Python and pip
install_python() {
    simple_header "Python Installation"
    
    if ! confirm "Do you want to install Python development tools?"; then
        warn "Skipping Python installation"
        return 0
    fi
    
    # Check what's already installed
    info "Checking current Python installation:"
    if command_exists python3; then
        echo "  ✅ Python3: $(python3 --version)"
    else
        echo "  ❌ Python3: Not installed"
    fi
    
    if command_exists pip3; then
        echo "  ✅ Pip3: $(pip3 --version | cut -d' ' -f1-2)"
    else
        echo "  ❌ Pip3: Not installed"
    fi
    
    if command_exists python3-venv || python3 -m venv --help >/dev/null 2>&1; then
        echo "  ✅ Python venv: Available"
    else
        echo "  ❌ Python venv: Not available"
    fi
    echo
    
    # Python packages to install
    local python_packages=(
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-dev"
        "python3-full"      # Required for virtual environments in newer Python
        "python-is-python3" # Makes 'python' command point to python3
        "pipx"              # For installing Python applications in isolated environments
    )
    
    show_progress "Installing Python development tools"
    
    if sudo nala install -y "${python_packages[@]}"; then
        show_success "Python development tools installed successfully"
        
        # Check if we're in an externally managed environment (PEP 668)
        if python3 -m pip install --help | grep -q "externally-managed-environment" 2>/dev/null; then
            info "Detected externally managed Python environment (PEP 668)"
            info "Using pipx for global Python applications and virtual environments for development"
        fi
        
        # Install common development packages via pipx (global applications)
        if confirm "Do you want to install common Python development tools via pipx?"; then
            show_progress "Installing Python development tools via pipx"
            
            # Install common tools that should be globally available
            local pipx_tools=("virtualenv" "black" "flake8" "pytest" "poetry")
            
            for tool in "${pipx_tools[@]}"; do
                if confirm "Install $tool via pipx?"; then
                    info "Installing $tool..."
                    if pipx install "$tool" 2>/dev/null; then
                        echo "  ✅ $tool installed successfully"
                    else
                        echo "  ⚠️  $tool installation failed (may already exist or be unavailable)"
                    fi
                fi
            done
            
            show_success "Python development tools installation completed"
        fi
        
        # Create a sample virtual environment to test
        if confirm "Do you want to create a sample virtual environment to test Python setup?"; then
            show_progress "Creating sample virtual environment"
            
            local venv_path="$HOME/python-test-env"
            
            if python3 -m venv "$venv_path"; then
                show_success "Sample virtual environment created at $venv_path"
                
                # Test pip in virtual environment
                info "Testing pip in virtual environment..."
                if "$venv_path/bin/python" -m pip install --upgrade pip setuptools wheel; then
                    echo "  ✅ Virtual environment pip working correctly"
                    
                    # Clean up test environment
                    if confirm "Remove the test virtual environment?"; then
                        rm -rf "$venv_path"
                        info "Test environment cleaned up"
                    else
                        info "Test environment kept at: $venv_path"
                        info "Activate with: source $venv_path/bin/activate"
                    fi
                else
                    warn "Virtual environment pip test failed"
                fi
            else
                show_error "Failed to create virtual environment"
            fi
        fi
        
    else
        show_error "Failed to install Python development tools"
        return 1
    fi
}

# Install Node.js, npm, and Next.js
install_nodejs() {
    simple_header "Node.js and npm Installation"
    
    if ! confirm "Do you want to install Node.js, npm, and Next.js?"; then
        warn "Skipping Node.js installation"
        return 0
    fi
    
    # Check current installation
    info "Checking current Node.js installation:"
    if command_exists node; then
        echo "  ✅ Node.js: $(node --version)"
    else
        echo "  ❌ Node.js: Not installed"
    fi
    
    if command_exists npm; then
        echo "  ✅ npm: $(npm --version)"
    else
        echo "  ❌ npm: Not installed"
    fi
    echo
    
    # Install Node.js from NodeSource (recommended repository for latest LTS)
    show_progress "Adding NodeSource repository for Node.js LTS"
    
    # Add NodeSource APT repository for Node.js LTS
    if curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -; then
        show_success "NodeSource repository added successfully"
        
        show_progress "Installing Node.js and npm from NodeSource"
        
        if sudo nala install -y nodejs; then
            show_success "Node.js and npm installed successfully"
            
            # Show versions
            info "Installed versions:"
            echo "  • Node.js: $(node --version)"
            echo "  • npm: $(npm --version)"
            echo
            
            # Update npm to latest compatible version
            local node_version=$(node --version | sed 's/v//')
            local node_major=$(echo "$node_version" | cut -d'.' -f1)
            
            if [[ $node_major -ge 20 ]]; then
                # Node.js 20+ can use latest npm
                show_progress "Updating npm to latest version"
                sudo npm install -g npm@latest
            elif [[ $node_major -eq 18 ]]; then
                # Node.js 18 should use compatible npm version
                show_progress "Installing compatible npm version for Node.js 18"
                sudo npm install -g npm@^10.0.0
            else
                # Keep existing npm for older versions
                info "Keeping existing npm version for Node.js $node_version"
            fi
        
        # Install Next.js CLI
        if confirm "Do you want to install Next.js CLI globally?"; then
            show_progress "Installing Next.js CLI"
            if sudo npm install -g create-next-app; then
                show_success "Next.js CLI installed successfully"
                info "You can now create Next.js apps with: npx create-next-app@latest"
            else
                warn "Failed to install Next.js CLI"
            fi
        fi
        
        # Install common global packages
        if confirm "Do you want to install common global npm packages (yarn, typescript, nodemon)?"; then
            show_progress "Installing common npm packages"
            local global_packages=("yarn" "typescript" "nodemon" "@types/node")
            
            for package in "${global_packages[@]}"; do
                info "Installing $package..."
                sudo npm install -g "$package"
            done
            
            show_success "Common npm packages installed"
            fi
            
        else
            show_error "Failed to install Node.js from NodeSource repository"
            return 1
        fi
        
    else
        show_error "Failed to add NodeSource repository"
        info "You can try installing Node.js manually from: https://nodejs.org/"
        return 1
    fi
}

# Install Gradle
install_gradle() {
    simple_header "Gradle Installation"
    
    if ! confirm "Do you want to install Gradle?"; then
        warn "Skipping Gradle installation"
        return 0
    fi
    
    # Check if SDKMAN is available for Gradle installation
    if [[ -d "$HOME/.sdkman" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        if confirm "Install Gradle via SDKMAN (recommended)?"; then
            show_progress "Installing Gradle via SDKMAN"
            
            if sdk install gradle; then
                show_success "Gradle installed successfully via SDKMAN"
                info "Gradle version: $(gradle --version | head -n 1)"
                return 0
            else
                warn "Failed to install Gradle via SDKMAN, trying APT package..."
            fi
        fi
    fi
    
    # Fallback to APT package
    show_progress "Installing Gradle via APT"
    
    if sudo nala install -y gradle; then
        show_success "Gradle installed successfully via APT"
        info "Gradle version: $(gradle --version | head -n 1)"
    else
        show_error "Failed to install Gradle"
        return 1
    fi
}

# Show development environment summary
show_dev_summary() {
    box "Development Languages - Installation Summary"
    
    info "🔧 Development Tools Installed:"
    
    # SDKMAN
    if [[ -d "$HOME/.sdkman" ]]; then
        echo "  ✅ SDKMAN - SDK Manager"
    fi
    
    # Java
    if command_exists java; then
        echo "  ✅ Java - $(java -version 2>&1 | head -n 1 | cut -d'"' -f2)"
        if [[ -n "$JAVA_HOME" ]]; then
            echo "    └─ JAVA_HOME: $JAVA_HOME"
        fi
    fi
    
    # Python
    if command_exists python3; then
        echo "  ✅ Python - $(python3 --version)"
        if command_exists pip3; then
            echo "    └─ Pip: $(pip3 --version | cut -d' ' -f1-2)"
        fi
        if command_exists pipx; then
            echo "    └─ Pipx: $(pipx --version)"
        fi
    fi
    
    # Node.js
    if command_exists node; then
        echo "  ✅ Node.js - $(node --version)"
        if command_exists npm; then
            echo "    └─ npm: $(npm --version)"
        fi
        if command_exists yarn; then
            echo "    └─ Yarn: $(yarn --version)"
        fi
    fi
    
    # Gradle
    if command_exists gradle; then
        echo "  ✅ Gradle - $(gradle --version | head -n 1 | awk '{print $2}')"
    fi
    
    echo
    success "Development languages setup completed! 🎉"
    
    echo
    info "📚 Quick Start Commands:"
    [[ -d "$HOME/.sdkman" ]] && echo "  • List Java versions: sdk list java"
    [[ -d "$HOME/.sdkman" ]] && echo "  • Switch Java version: sdk use java <version>"
    if command_exists python3; then
        echo "  • Create Python virtual env: python3 -m venv myenv"
        echo "  • Activate virtual env: source myenv/bin/activate"
        command_exists pipx && echo "  • Install Python apps: pipx install <package>"
    fi
    command_exists npm && echo "  • Create Next.js app: npx create-next-app@latest myapp"
    command_exists gradle && echo "  • Initialize Gradle project: gradle init"
    
    echo
    info "🔄 Environment Setup:"
    echo "  • Restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to update PATH"
    echo "  • SDKMAN commands will be available in new terminal sessions"
    echo "  • Java environment variables are managed by SDKMAN"
}

# Main execution
main() {
    box "Development Languages Installation"
    
    info "This module installs programming languages and development tools:"
    echo
    echo "☕ Java Development:"
    echo "   • SDKMAN - Software Development Kit Manager"
    echo "   • Java JDK (multiple versions available: Oracle, Temurin, GraalVM, etc.)"
    echo "   • User choice for Java version and default setting"
    echo
    echo "🐍 Python Development:"
    echo "   • Python 3 with pip, venv, and full development environment"
    echo "   • pipx for global Python applications (PEP 668 compliant)"
    echo "   • Virtual environment testing and common development tools"
    echo
    echo "🟢 Node.js Development:"
    echo "   • Node.js runtime and npm package manager"
    echo "   • Next.js CLI for React applications"
    echo "   • Common global packages (yarn, typescript, nodemon)"
    echo
    echo "🏗️  Build Tools:"
    echo "   • Gradle build automation tool"
    echo "   • Integration with SDKMAN for version management"
    echo
    warn "Prerequisites: Requires curl and basic build tools (install 'Essential Packages' first)"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! command_exists curl; then
        error "curl is required but not installed. Please run 'Essential Packages' module first."
        exit 1
    fi
    
    if ! confirm "Do you want to proceed with development languages installation?"; then
        warn "Development languages installation cancelled by user"
        exit 0
    fi
    
    echo
    
    # Install SDKMAN first
    install_sdkman
    
    # Install Java via SDKMAN
    echo
    install_java_sdkman
    
    # Install Python
    echo
    install_python
    
    # Install Node.js and Next.js
    echo
    install_nodejs
    
    # Install Gradle
    echo
    install_gradle
    
    # Show summary
    echo
    show_dev_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi