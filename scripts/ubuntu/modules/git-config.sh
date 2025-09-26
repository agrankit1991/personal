#!/bin/bash

# Git Configuration Module
# Complete Git setup including configuration, SSH keys, and global gitignore

set -e

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

# Source utilities and colors
source "$LIB_DIR/utils.sh"

# Git configuration function
configure_git_basics() {
    simple_header "Basic Git Configuration"
    
    # Check if Git is installed
    if ! command_exists git; then
        error "Git is not installed. Please install it first using the Essential Packages module."
        return 1
    fi
    
    # Get user information
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" && -n "$current_email" ]]; then
        info "Current Git configuration:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
        echo
        if ! confirm "Do you want to update your Git configuration?"; then
            info "Keeping existing Git configuration"
            return 0
        fi
    fi
    
    # Get user input
    echo "Enter your Git configuration details:"
    read -p "Full Name: " git_name
    read -p "Email Address: " git_email
    
    if [[ -z "$git_name" || -z "$git_email" ]]; then
        error "Name and email are required for Git configuration"
        return 1
    fi
    
    show_progress "Configuring Git identity"
    
    # Set basic configuration
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    # Set default branch name to main
    git config --global init.defaultBranch main
    
    # Configure line endings for Linux
    git config --global core.autocrlf input
    
    # Enable colorized output
    git config --global color.ui true
    
    # Set pull behavior to use rebase
    git config --global pull.rebase true
    
    # Configure default editor based on what's available
    if command_exists code; then
        git config --global core.editor "code --wait"
        info "Set VS Code as default Git editor"
    elif command_exists vim; then
        git config --global core.editor "vim"
        info "Set Vim as default Git editor"
    else
        git config --global core.editor "nano"
        info "Set Nano as default Git editor"
    fi
    
    show_success "Git basic configuration completed"
    echo "  Name: $git_name"
    echo "  Email: $git_email"
    echo
}

# Configure Git aliases
configure_git_aliases() {
    simple_header "Git Aliases"
    
    if ! confirm "Do you want to install useful Git aliases?"; then
        warn "Skipping Git aliases configuration"
        return 0
    fi
    
    show_progress "Setting up Git aliases"
    
    # Common operations
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    
    # Useful log formats
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.lp "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
    
    # Additional useful aliases
    git config --global alias.ls "log --pretty=format:'%C(yellow)%h %C(blue)%ad%C(red)%d %C(reset)%s%C(green) [%cn]' --decorate --date=short"
    git config --global alias.ll "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate --numstat"
    git config --global alias.ld "log --pretty=format:'%C(yellow)%h %C(white)%s %Cblue[%cn]' --decorate --date=short"
    git config --global alias.lds "log --pretty=format:'%C(yellow)%h %C(white)%s %Cblue[%cn]' --decorate --date=short --graph"
    
    show_success "Git aliases configured successfully"
    info "Available aliases: st, co, br, ci, unstage, last, lg, lp, ls, ll, ld, lds"
    echo
}

# Setup SSH keys for GitHub
setup_ssh_keys() {
    simple_header "SSH Key Setup for GitHub"
    
    local email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$email" ]]; then
        error "Git email not configured. Please run Git basic configuration first."
        return 1
    fi
    
    # Check if SSH key already exists
    if [[ -f ~/.ssh/id_ed25519 ]]; then
        info "SSH key already exists at ~/.ssh/id_ed25519"
        if ! confirm "Do you want to create a new SSH key? (This will backup the existing one)"; then
            info "Using existing SSH key"
            show_ssh_public_key
            return 0
        fi
        
        # Backup existing key
        backup_file ~/.ssh/id_ed25519
        backup_file ~/.ssh/id_ed25519.pub
    fi
    
    show_progress "Generating SSH key"
    
    # Generate SSH key
    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    
    # Create SSH config
    ensure_dir ~/.ssh
    
    if [[ ! -f ~/.ssh/config ]] || ! grep -q "github.com" ~/.ssh/config; then
        show_progress "Creating SSH config"
        cat >> ~/.ssh/config << EOL

Host github.com
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
EOL
        chmod 600 ~/.ssh/config
    fi
    
    # Add key to ssh-agent
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
    
    show_success "SSH key generated successfully"
    show_ssh_public_key
}

# Show SSH public key for copying to GitHub
show_ssh_public_key() {
    box "SSH Public Key"
    
    if [[ -f ~/.ssh/id_ed25519.pub ]]; then
        info "Copy this SSH public key to your GitHub account:"
        echo
        highlight "$(cat ~/.ssh/id_ed25519.pub)"
        echo
        
        # Try to copy to clipboard if available
        if command_exists xclip; then
            cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
            success "SSH key copied to clipboard!"
        elif command_exists wl-copy; then
            cat ~/.ssh/id_ed25519.pub | wl-copy
            success "SSH key copied to clipboard!"
        else
            warn "Clipboard utility not found. Please copy the key manually."
        fi
        
        echo
        info "To add this key to GitHub:"
        echo "  1. Go to GitHub.com → Settings → SSH and GPG keys"
        echo "  2. Click 'New SSH key'"
        echo "  3. Paste the key and give it a meaningful title"
        echo "  4. Click 'Add SSH key'"
        
        if confirm "Press Enter after adding the key to GitHub to test the connection..."; then
            test_github_connection
        fi
    else
        error "SSH key not found at ~/.ssh/id_ed25519.pub"
        return 1
    fi
}

# Test GitHub SSH connection
test_github_connection() {
    show_progress "Testing GitHub SSH connection"
    
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        show_success "GitHub SSH connection successful!"
    else
        show_warning "GitHub SSH connection test failed. Please check your key configuration."
    fi
    echo
}

# Setup global gitignore
setup_global_gitignore() {
    simple_header "Global Git Ignore"
    
    if ! confirm "Do you want to create a global .gitignore file?"; then
        warn "Skipping global gitignore setup"
        return 0
    fi
    
    show_progress "Creating global gitignore file"
    
    # Backup existing file if it exists
    [[ -f ~/.gitignore_global ]] && backup_file ~/.gitignore_global
    
    cat > ~/.gitignore_global << 'EOL'
# Linux system files
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# macOS system files
.DS_Store
.AppleDouble
.LSOverride
Icon

# Windows system files
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# IDE specific files
.idea/
.vscode/
*.sublime-workspace
*.sublime-project
*.swp
*.swo
*~

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.node_repl_history

# Python
*.py[cod]
*$py.class
__pycache__/
*.so
.Python
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
*.egg-info/
dist/
build/

# Java
*.class
*.log
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*

# Gradle
.gradle/
build/
gradle-app.setting
!gradle-wrapper.jar
!gradle-wrapper.properties
.gradletasknamecache

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# IntelliJ IDEA
*.iws
*.iml
*.ipr
out/

# Eclipse
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache
bin/
tmp/
*.tmp
*.bak
*.swp
*~.nib
local.properties
.metadata
.recommenders

# Android
*.apk
*.ap_
*.dex
local.properties
proguard/
*.log

# Temporary files
*.tmp
*.temp
*.log
*.cache

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Database
*.db
*.sqlite
*.sqlite3

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# Compiled binary addons
build/Release

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity
EOL
    
    # Configure Git to use this global gitignore
    git config --global core.excludesfile ~/.gitignore_global
    
    show_success "Global gitignore created and configured"
    info "Location: ~/.gitignore_global"
    echo
}

# Setup Git commit message template
setup_commit_template() {
    simple_header "Git Commit Template"
    
    if ! confirm "Do you want to create a commit message template?"; then
        warn "Skipping commit template setup"
        return 0
    fi
    
    show_progress "Creating commit message template"
    
    cat > ~/.gitmessage << 'EOL'
# <type>: <subject>

# <body>

# <footer>

# Types:
#   feat     (new feature)
#   fix      (bug fix)
#   docs     (changes to documentation)
#   style    (formatting, missing semi colons, etc; no code change)
#   refactor (refactoring production code)
#   test     (adding missing tests, refactoring tests)
#   chore    (updating grunt tasks etc; no production code change)

# Subject should be no greater than 50 characters
# Body should be wrapped at 72 characters
# Use the imperative mood in the subject line
EOL
    
    # Set it as default commit template
    git config --global commit.template ~/.gitmessage
    
    show_success "Commit template created and configured"
    info "Use 'git commit' (without -m) to use the template"
    echo
}

# Setup credential helper
setup_credential_helper() {
    simple_header "Git Credential Helper"
    
    if ! confirm "Do you want to setup secure credential storage?"; then
        warn "Skipping credential helper setup"
        return 0
    fi
    
    show_progress "Installing credential helper dependencies"
    
    # Install libsecret for secure credential storage
    if ! package_installed "libsecret-1-0"; then
        sudo nala install -y libsecret-1-0 libsecret-1-dev
    fi
    
    # Build credential helper if it doesn't exist
    if [[ ! -f /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret ]]; then
        show_progress "Building Git credential helper"
        sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
    fi
    
    # Configure Git to use libsecret
    git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    
    show_success "Credential helper configured"
    info "Git will now securely store your credentials"
    echo
}

# Install additional Git tools
install_git_tools() {
    simple_header "Additional Git Tools"
    
    local tools_to_install=()
    
    info "Available Git tools to install:"
    echo "  • gitk - Graphical history viewer"
    echo "  • git-gui - GUI for Git operations"
    echo "  • meld - Visual diff and merge tool"
    echo "  • xclip - Clipboard utility for SSH keys"
    echo
    
    if confirm "Do you want to install additional Git tools?"; then
        show_progress "Installing Git tools"
        
        # Add tools that aren't installed
        ! package_installed "gitk" && tools_to_install+=("gitk")
        ! package_installed "git-gui" && tools_to_install+=("git-gui")
        ! package_installed "meld" && tools_to_install+=("meld")
        ! command_exists "xclip" && tools_to_install+=("xclip")
        
        if [[ ${#tools_to_install[@]} -gt 0 ]]; then
            sudo nala install -y "${tools_to_install[@]}"
            
            # Configure meld as diff/merge tool if installed
            if command_exists meld; then
                git config --global merge.tool meld
                git config --global diff.tool meld
                info "Configured meld as default diff/merge tool"
            fi
            
            show_success "Git tools installed successfully"
        else
            info "All Git tools are already installed"
        fi
    else
        warn "Skipping additional Git tools installation"
    fi
    echo
}

# Show configuration summary
show_git_summary() {
    box "Git Configuration Summary"
    
    info "Git configuration:"
    echo "  Name: $(git config --global user.name 2>/dev/null || echo 'Not configured')"
    echo "  Email: $(git config --global user.email 2>/dev/null || echo 'Not configured')"
    echo "  Default Branch: $(git config --global init.defaultBranch 2>/dev/null || echo 'Not configured')"
    echo "  Editor: $(git config --global core.editor 2>/dev/null || echo 'Not configured')"
    
    echo
    info "Files created:"
    [[ -f ~/.gitignore_global ]] && echo "  ✅ Global gitignore: ~/.gitignore_global"
    [[ -f ~/.gitmessage ]] && echo "  ✅ Commit template: ~/.gitmessage"
    [[ -f ~/.ssh/id_ed25519 ]] && echo "  ✅ SSH key: ~/.ssh/id_ed25519"
    [[ -f ~/.ssh/config ]] && echo "  ✅ SSH config: ~/.ssh/config"
    
    echo
    info "Available Git aliases:"
    git config --global --get-regexp alias 2>/dev/null | sed 's/alias\./  /'
    
    echo
    success "Git configuration completed! 🎉"
    
    echo
    info "Next steps:"
    echo "  - Add your SSH key to GitHub if you haven't already"
    echo "  - Test cloning a repository: 'git clone git@github.com:username/repo.git'"
    echo "  - Use 'git config --list' to see all configurations"
    echo "  - Try the new aliases like 'git st' for status"
}

# Main execution
main() {
    box "Git Configuration Setup"
    
    info "This module will configure Git with:"
    echo
    echo "🔧 Basic Configuration:"
    echo "   • User identity (name and email)"
    echo "   • Default settings and editor"
    echo "   • Useful aliases"
    echo
    echo "🔐 SSH Setup:"
    echo "   • Generate SSH keys for GitHub"
    echo "   • Configure SSH agent"
    echo "   • Test GitHub connection"
    echo
    echo "📁 Additional Setup:"
    echo "   • Global .gitignore (including Gradle support)"
    echo "   • Commit message template"
    echo "   • Secure credential storage"
    echo "   • Additional Git tools"
    echo
    
    # Check prerequisites
    if ! check_nala; then
        exit 1
    fi
    
    if ! command_exists git; then
        error "Git is not installed. Please install it first using the Essential Packages module."
        info "Run the setup script and select option 2 (Install Essential Packages)"
        exit 1
    fi
    
    if ! confirm "Do you want to continue with Git configuration?"; then
        warn "Git configuration cancelled by user"
        exit 0
    fi
    
    # Execute configuration steps
    echo
    configure_git_basics
    configure_git_aliases
    setup_ssh_keys
    setup_global_gitignore
    setup_commit_template
    setup_credential_helper
    install_git_tools
    
    show_git_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi