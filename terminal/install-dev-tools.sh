#!/bin/bash

# Development Tools Install Script for Arch Linux
# Installs Docker, docker-compose, and mise-managed dev tools (Java, Node, Gradle)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===============================
# Package List
# ===============================
# Format: "command:package-name"
PACKAGES=(
    "docker:docker"
    "docker-compose:docker-compose"
)

# ===============================
# Mise Tools List
# ===============================
# Format: "tool@version"
MISE_TOOLS=(
    "java@temurin-21"
    "node@lts"
    "gradle@latest"
)

# ===============================
# Helpers
# ===============================

# Equivalent to the 'installl' zsh alias: paru -S --needed
installl() {
    paru -S --needed --noconfirm "$@"
}

# Check if a mise tool/version is already configured globally
mise_is_installed() {
    local tool="$1"
    local version="$2"
    grep -q "^${tool} =.*${version}" ~/.config/mise/config.toml 2>/dev/null
}

echo "========================================"
echo "Development Tools Install Script"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# Ensure paru is available
echo "Checking for paru (AUR helper)..."
if ! command -v paru &> /dev/null; then
    echo "Error: paru is not installed. Please run install.sh first, or install paru manually."
    exit 1
fi
echo "✓ paru found"

# Ensure mise is available
echo "Checking for mise..."
if ! command -v mise &> /dev/null; then
    echo "Error: mise is not installed. Please run install.sh first, or install mise manually."
    exit 1
fi
echo "✓ mise found"
echo ""

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm

echo ""
echo "========================================"
echo "Installing System Packages"
echo "========================================"
echo ""

# Install each package from the list
for pkg_info in "${PACKAGES[@]}"; do
    cmd="${pkg_info%%:*}"
    pkg="${pkg_info##*:}"

    echo "Installing ${pkg}..."
    if command -v "$cmd" &> /dev/null; then
        echo "✓ ${pkg} is already installed"
    else
        installl "$pkg"
        echo "✓ ${pkg} installed"
    fi
    echo ""
done

echo ""
echo "========================================"
echo "Configuring Docker"
echo "========================================"
echo ""

# Enable and start docker service
if systemctl is-active --quiet docker; then
    echo "✓ Docker service is already running"
else
    echo "Enabling and starting docker service..."
    sudo systemctl enable --now docker.service
    echo "✓ Docker service enabled and started"
fi

# Add user to docker group
if id -nG "$USER" | grep -qw docker; then
    echo "✓ User '$USER' is already in the docker group"
else
    echo "Adding user '$USER' to the docker group..."
    sudo usermod -aG docker "$USER"
    echo "✓ User added to docker group"
    echo ""
    echo "IMPORTANT: You must log out and log back in (or run 'newgrp docker')"
    echo "           for docker group changes to take full effect."
    newgrp docker || true
fi

echo ""
echo "========================================"
echo "Installing Mise Development Tools"
echo "========================================"
echo ""

for tool_spec in "${MISE_TOOLS[@]}"; do
    tool="${tool_spec%%@*}"
    version="${tool_spec##*@}"

    echo "Installing ${tool_spec}..."
    if mise_is_installed "$tool" "$version"; then
        echo "✓ ${tool_spec} is already configured"
    else
        mise use -g "$tool_spec"
        echo "✓ ${tool_spec} installed and set as global default"
    fi
    echo ""
done

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Installed system packages:"
for pkg_info in "${PACKAGES[@]}"; do
    pkg="${pkg_info##*:}"
    echo "  ✓ ${pkg}"
done
echo ""
echo "Installed mise tools:"
for tool_spec in "${MISE_TOOLS[@]}"; do
    echo "  ✓ ${tool_spec}"
done
echo ""
echo "Docker commands:"
echo "  docker compose up -d       - Run docker stack"
echo "  docker start postgres_dev  - Start database manually"
echo "  docker stop postgres_dev   - Stop database"
echo ""
echo "Database restore example:"
echo "  cat arthasagar.dump | docker exec -i postgres_dev pg_restore -U \"bawandar\" -C -c --no-owner -d \"postgres\""
echo ""
