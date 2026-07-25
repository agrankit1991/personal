#!/bin/bash

# GUI & Dev Apps Install Script for Arch Linux
# Installs VS Code, OpenCode (AI coding agent), and Brave Browser

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===============================
# Package List
# ===============================
# Format: "command:package-name"
# command = binary to check if already installed
# package-name = pacman/aur package name
PACKAGES=(
    "opencode:opencode"
    "code:visual-studio-code-bin"
    "brave:brave-bin"
)

# ===============================
# Helpers
# ===============================

# Equivalent to the 'installl' zsh alias: paru -S --needed
installl() {
    paru -S --needed --noconfirm "$@"
}

echo "========================================"
echo "GUI & Dev Apps Install Script"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root"
    exit 1
fi

# Ensure paru is available (needed for AUR packages and installl alias)
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
echo "Installing Packages"
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
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Installed applications:"
for pkg_info in "${PACKAGES[@]}"; do
    cmd="${pkg_info%%:*}"
    pkg="${pkg_info##*:}"
    echo "  ✓ ${pkg}"
done
echo ""
echo "Next steps:"
echo "  1. Run 'opencode --version' to verify OpenCode"
echo "  2. Run 'code' to launch VS Code"
echo "  3. Run 'brave' to launch Brave Browser"
echo ""
echo "Optional OpenCode setup:"
echo "  - Run 'opencode init' to configure your API keys"
echo "  - Add API keys to ~/.zshrc:"
echo "      export ANTHROPIC_API_KEY='sk-ant-...'"
echo "      export OPENAI_API_KEY='sk-...'"
echo ""
