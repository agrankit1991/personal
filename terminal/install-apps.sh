#!/bin/bash

# GUI & Dev Apps Install Script for Arch Linux
# Installs VS Code:, OpenCode (AI coding agent), Brave Browser,
# and Flatpak apps (Obsidian, Bazaar, OnlyOffice, Thunderbird, DBeaver)

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
# Flatpak App List
# ===============================
# Format: "app-id"
FLATPAK_APPS=(
    "md.obsidian.Obsidian"
    "io.github.kolunmi.Bazaar"
    "org.onlyoffice.desktopeditors"
    "org.mozilla.Thunderbird"
    "io.dbeaver.DBeaverCommunity"
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

# ===============================
# Flatpak Setup & Installation
# ===============================

echo ""
echo "========================================"
echo "Setting up Flatpak & Flathub"
echo "========================================"
echo ""

# Install flatpak if not present
echo "Checking for flatpak..."
if ! command -v flatpak &> /dev/null; then
    echo "Installing flatpak..."
    installl flatpak
    echo "✓ flatpak installed"
else
    echo "✓ flatpak already installed"
fi
echo ""

# Add flathub remote if not present
echo "Checking for flathub remote..."
if ! flatpak remotes | grep -q "flathub"; then
    echo "Adding flathub remote..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "✓ flathub remote added"
else
    echo "✓ flathub remote already configured"
fi
echo ""

# Install flatpak apps
echo "========================================"
echo "Installing Flatpak Applications"
echo "========================================"
echo ""

for app_id in "${FLATPAK_APPS[@]}"; do
    app_name="${app_id##*.}"
    echo "Installing ${app_name} (${app_id})..."
    if flatpak list --app | grep -q "${app_id}"; then
        echo "✓ ${app_name} is already installed"
    else
        flatpak install -y flathub "${app_id}"
        echo "✓ ${app_name} installed"
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
for app_id in "${FLATPAK_APPS[@]}"; do
    app_name="${app_id##*.}"
    echo "  ✓ ${app_name} (flatpak)"
done
echo ""
echo "Next steps:"
echo "  1. Run 'opencode --version' to verify OpenCode"
echo "  2. Run 'code' to launch VS Code:"
echo "  3. Run 'brave' to launch Brave Browser"
echo "  4. Launch flatpak apps from your app menu or with:"
echo "      flatpak run md.obsidian.Obsidian"
echo "      flatpak run io.github.kolunmi.Bazaar"
echo "      flatpak run org.onlyoffice.desktopeditors"
echo "      flatpak run org.mozilla.Thunderbird"
echo "      flatpak run io.dbeaver.DBeaverCommunity"
echo ""
echo "Optional OpenCode setup:"
echo "  - Run 'opencode init' to configure your API keys"
echo "  - Add API keys to ~/.zshrc:"
echo "      export ANTHROPIC_API_KEY='sk-ant-...'"
echo "      export OPENAI_API_KEY='sk-...'"
echo ""
