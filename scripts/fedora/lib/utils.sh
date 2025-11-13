#!/bin/bash

# Utility functions for Fedora setup scripts
# Usage: source this file to use utility functions

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR"

# Source colors if available
if [[ -f "$LIB_DIR/colors.sh" ]]; then
    source "$LIB_DIR/colors.sh"
fi

# Logging functions
log() {
    echo -e "${SUCCESS}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${WARNING}[WARNING] $1${NC}"
}

error() {
    echo -e "${ERROR}[ERROR] $1${NC}"
}

info() {
    echo -e "${INFO}[INFO] $1${NC}"
}

success() {
    echo -e "${SUCCESS}[SUCCESS] $1${NC}"
}

highlight() {
    echo -e "${HIGHLIGHT}$1${NC}"
}

header() {
    echo -e "${HEADER}$1${NC}"
}

# Progress indicator
show_progress() {
    local message="$1"
    echo -e "${INFO}⏳ $message...${NC}"
}

# Success indicator with checkmark
show_success() {
    local message="$1"
    echo -e "${SUCCESS}✅ $message${NC}"
}

# Error indicator with X mark
show_error() {
    local message="$1"
    echo -e "${ERROR}❌ $message${NC}"
}

# Warning indicator
show_warning() {
    local message="$1"
    echo -e "${WARNING}⚠️  $message${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if DNF package is installed
dnf_package_installed() {
    rpm -q "$1" &>/dev/null
}

# Check if Flatpak app is installed
flatpak_app_installed() {
    local app_id="$1"
    flatpak list --app 2>/dev/null | grep -q "$app_id"
}

# Generic check if app is installed (checks both DNF and Flatpak)
is_app_installed() {
    local app_name="$1"
    local flatpak_id="${2:-}"  # Optional Flatpak ID
    
    # Check if it's a command
    if command_exists "$app_name"; then
        return 0
    fi
    
    # Check DNF packages
    if dnf_package_installed "$app_name"; then
        return 0
    fi
    
    # Check Flatpak if ID provided
    if [[ -n "$flatpak_id" ]] && command_exists flatpak; then
        if flatpak_app_installed "$flatpak_id"; then
            return 0
        fi
    fi
    
    return 1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if running as regular user
is_user() {
    [[ $EUID -ne 0 ]]
}

# Prompt for yes/no confirmation
confirm() {
    local message="${1:-Do you want to continue?}"
    local default="${2:-Y}" # Default to Yes
    
    if [[ "$default" == "Y" || "$default" == "y" ]]; then
        read -p "$message [Y/n]: " -n 1 -r
    else
        read -p "$message [y/N]: " -n 1 -r
    fi
    
    echo # Move to new line
    
    if [[ "$default" == "Y" || "$default" == "y" ]]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Create a separator line
separator() {
    local char="${1:-=}"
    local length="${2:-60}"
    printf "%*s\n" "$length" | tr ' ' "$char"
}

# Create a box around text
box() {
    local text="$1"
    local width=${#text}
    local padding=4
    local total_width=$((width + padding * 2))
    
    echo -e "${HEADER}"
    # Top border
    printf "╔"
    for ((i=0; i<total_width; i++)); do printf "═"; done
    printf "╗\n"
    
    # Middle with text
    printf "║"
    for ((i=0; i<padding; i++)); do printf " "; done
    printf "%s" "$text"
    for ((i=0; i<padding; i++)); do printf " "; done
    printf "║\n"
    
    # Bottom border
    printf "╚"
    for ((i=0; i<total_width; i++)); do printf "═"; done
    printf "╝\n"
    echo -e "${NC}"
}

# Create a simple header
simple_header() {
    local text="$1"
    echo
    echo -e "${HEADER}$text${NC}"
    echo -e "${HEADER}$(printf '%*s' ${#text} | tr ' ' '=')${NC}"
    echo
}

# Show a spinner for long-running operations
spinner() {
    local pid=$1
    local message="${2:-Processing}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${INFO}${spin:$i:1} $message...${NC}"
        sleep .1
    done
    
    printf "\r"
}

# Wait for user to press Enter
pause() {
    local message="${1:-Press Enter to continue...}"
    read -p "$message"
}

# Get system information
get_os_info() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$NAME $VERSION"
    else
        uname -s
    fi
}

# Check if system is Fedora
is_fedora() {
    [[ -f /etc/os-release ]] && grep -q "Fedora" /etc/os-release
}

# Get Fedora version
get_fedora_version() {
    if is_fedora; then
        grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"'
    fi
}

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Backup a file with timestamp
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        info "Backed up $file to $backup"
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        info "Created directory: $dir"
    fi
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    local description="${3:-Downloading file}"
    
    show_progress "$description"
    
    if command_exists wget; then
        wget -q --show-progress -O "$output" "$url"
    elif command_exists curl; then
        curl -L -o "$output" "$url"
    else
        error "Neither wget nor curl is available for downloading"
        return 1
    fi
}

# Add line to file if it doesn't exist
add_line_to_file() {
    local line="$1"
    local file="$2"
    
    if ! grep -Fq "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        info "Added line to $file: $line"
    fi
}

# Remove line from file
remove_line_from_file() {
    local pattern="$1"
    local file="$2"
    
    if [[ -f "$file" ]]; then
        sed -i "/$pattern/d" "$file"
        info "Removed lines matching '$pattern' from $file"
    fi
}

# Install DNF package with confirmation
install_dnf_package() {
    local package="$1"
    local description="${2:-$package}"
    
    if dnf_package_installed "$package"; then
        info "$description is already installed (DNF)"
        return 0
    fi
    
    if confirm "Install $description?"; then
        show_progress "Installing $description via DNF"
        if sudo dnf install -y "$package"; then
            show_success "$description installed successfully"
            return 0
        else
            show_error "Failed to install $description"
            return 1
        fi
    else
        warn "Skipping $description installation"
        return 0
    fi
}

# Install Flatpak app with confirmation
install_flatpak_app() {
    local app_id="$1"
    local app_name="${2:-$app_id}"
    
    if ! command_exists flatpak; then
        error "Flatpak is not installed. Please run 'Essential Packages' module first."
        return 1
    fi
    
    if flatpak_app_installed "$app_id"; then
        info "$app_name is already installed (Flatpak)"
        return 0
    fi
    
    if confirm "Install $app_name via Flatpak?"; then
        show_progress "Installing $app_name via Flatpak"
        if flatpak install -y flathub "$app_id"; then
            show_success "$app_name installed successfully"
            return 0
        else
            show_error "Failed to install $app_name"
            return 1
        fi
    else
        warn "Skipping $app_name installation"
        return 0
    fi
}

# Setup Flathub repository
setup_flathub() {
    if ! command_exists flatpak; then
        error "Flatpak is not installed"
        return 1
    fi
    
    if flatpak remotes | grep -q flathub; then
        info "Flathub repository is already configured"
        return 0
    fi
    
    show_progress "Adding Flathub repository"
    if sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
        show_success "Flathub repository added successfully"
        return 0
    else
        show_error "Failed to add Flathub repository"
        return 1
    fi
}

# Enable RPM Fusion repositories
enable_rpmfusion() {
    if dnf repolist | grep -q "rpmfusion-free"; then
        info "RPM Fusion repositories are already enabled"
        return 0
    fi
    
    if confirm "Enable RPM Fusion repositories (Free and Non-Free)?"; then
        show_progress "Enabling RPM Fusion repositories"
        local fedora_version=$(get_fedora_version)
        
        if sudo dnf install -y \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"; then
            show_success "RPM Fusion repositories enabled"
            return 0
        else
            show_error "Failed to enable RPM Fusion repositories"
            return 1
        fi
    else
        warn "Skipping RPM Fusion installation"
        return 0
    fi
}

# Export functions that should be available to sourcing scripts
export -f log warn error info success highlight header
export -f show_progress show_success show_error show_warning
export -f command_exists dnf_package_installed flatpak_app_installed is_app_installed
export -f is_root is_user confirm
export -f separator box simple_header pause spinner
export -f get_os_info is_fedora get_fedora_version check_internet
export -f backup_file ensure_dir download_file
export -f add_line_to_file remove_line_from_file
export -f install_dnf_package install_flatpak_app setup_flathub enable_rpmfusion
