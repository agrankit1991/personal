#!/bin/bash

# COSMIC Desktop Setup Script for Arch Linux
# Installs xdg-desktop-portal-gtk and configures greeter keyboard settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===============================
# Package List
# ===============================
# Format: "command:package-name"
PACKAGES=(
    "xdg-desktop-portal-gtk:xdg-desktop-portal-gtk"
)

# ===============================
# Helpers
# ===============================

# Equivalent to the 'installl' zsh alias: paru -S --needed
installl() {
    paru -S --needed --noconfirm "$@"
}

echo "========================================"
echo "COSMIC Desktop Setup Script"
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
echo ""

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm

echo ""
echo "========================================"
echo "Installing Portal Package"
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
echo "Configuring COSMIC Greeter"
echo "========================================"
echo ""

# Configure numlock state for cosmic-greeter
GREETER_CONFIG_DIR="/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1"
GREETER_CONFIG_FILE="${GREETER_CONFIG_DIR}/keyboard_config"

# Create directory if it doesn't exist
if [ ! -d "$GREETER_CONFIG_DIR" ]; then
    echo "Creating greeter config directory..."
    sudo mkdir -p "$GREETER_CONFIG_DIR"
    echo "✓ Created ${GREETER_CONFIG_DIR}"
fi

# Write keyboard config (root-owned, as expected for system paths)
echo "Setting numlock state to BootOn for greeter..."
sudo tee "$GREETER_CONFIG_FILE" > /dev/null <<'EOF'
(
numlock_state: BootOn,
)
EOF

echo "✓ Configured ${GREETER_CONFIG_FILE}"
echo "  (To edit later, use: sudo nvim $GREETER_CONFIG_FILE)"
echo ""

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Installed/configured:"
for pkg_info in "${PACKAGES[@]}"; do
    pkg="${pkg_info##*:}"
    echo "  ✓ ${pkg}"
done
echo "  ✓ COSMIC greeter numlock config"
echo ""
