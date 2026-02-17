#!/bin/bash

# Terminal Setup Script for Arch Linux
# Sets up a modern terminal environment with Zsh, Starship, and essential CLI tools

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "Terminal Setup Script"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Please do not run this script as root"
    exit 1
fi

# Verify required files exist
echo "Checking for required configuration files..."
if [ ! -f "$SCRIPT_DIR/.zshrc" ]; then
    echo "Error: .zshrc not found in current directory"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/starship.toml" ]; then
    echo "Error: starship.toml not found in current directory"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/zsh" ]; then
    echo "Error: zsh directory not found in current directory"
    exit 1
fi

echo "✓ All required files found"
echo ""

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm

# Install packages
echo ""
echo "Installing packages..."
sudo pacman -S --needed --noconfirm \
    neovim \
    zsh \
    ripgrep \
    fd \
    bat \
    eza \
    zoxide \
    duf \
    ncdu \
    fzf \
    tldr \
    tree \
    btop \
    man-db \
    cmatrix \
    rust \
    unzip \
    wget

echo ""
echo "Installing JetBrainsMono Nerd Font..."
sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd

echo ""
echo "Installing mise..."
curl https://mise.run | sh

echo ""
echo "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh

# Copy configuration files
echo ""
echo "Copying configuration files..."

# Backup existing .zshrc if it exists
if [ -f ~/.zshrc ]; then
    echo "Backing up existing .zshrc to ~/.zshrc.backup"
    cp ~/.zshrc ~/.zshrc.backup
fi

# Copy .zshrc
cp "$SCRIPT_DIR/.zshrc" ~/
echo "✓ Copied .zshrc to ~/"

# Create .config directory if it doesn't exist
mkdir -p ~/.config

# Backup existing starship.toml if it exists
if [ -f ~/.config/starship.toml ]; then
    echo "Backing up existing starship.toml to ~/.config/starship.toml.backup"
    cp ~/.config/starship.toml ~/.config/starship.toml.backup
fi

# Copy starship.toml
cp "$SCRIPT_DIR/starship.toml" ~/.config/
echo "✓ Copied starship.toml to ~/.config/"

# Backup existing zsh config directory if it exists
if [ -d ~/.config/zsh ]; then
    echo "Backing up existing ~/.config/zsh to ~/.config/zsh.backup"
    mv ~/.config/zsh ~/.config/zsh.backup
fi

# Copy zsh directory
cp -r "$SCRIPT_DIR/zsh" ~/.config/
echo "✓ Copied zsh directory to ~/.config/"


# Change default shell to zsh
echo ""
echo "Changing default shell to zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    echo "✓ Default shell changed to zsh"
else
    echo "✓ Zsh is already the default shell"
fi

# Install Oh My Zsh and plugins
echo ""
echo "Installing Oh My Zsh..."

# Backup existing .zshrc since oh-my-zsh will replace it
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.pre-omz
fi

# Install Oh My Zsh (non-interactive)
export RUNZSH=no
export KEEP_ZSHRC=yes
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Restore our custom .zshrc
if [ -f ~/.zshrc.pre-omz ]; then
    mv ~/.zshrc.pre-omz ~/.zshrc
    echo "✓ Restored custom .zshrc"
fi

echo ""
echo "Installing Oh My Zsh plugins..."

# Install zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
echo "✓ Installed zsh-completions"

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "✓ Installed zsh-syntax-highlighting"

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "✓ Installed zsh-autosuggestions"

# Install k (directory listings)
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k
echo "✓ Installed k plugin"

# Install LazyVim
echo ""
echo "Installing LazyVim configuration for Neovim..."

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim
echo "✓ Cloned LazyVim starter"

# Remove .git directory to make it your own
rm -rf ~/.config/nvim/.git
echo "✓ Removed LazyVim .git directory"

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Installed tools:"
echo "  ✓ Zsh (shell)"
echo "  ✓ Oh My Zsh (framework)"
echo "  ✓ Starship (prompt)"
echo "  ✓ Mise (version manager)"
echo "  ✓ Neovim (editor)"
echo "  ✓ LazyVim (Neovim config)"
echo "  ✓ Modern CLI tools (ripgrep, fd, bat, eza, zoxide, fzf, etc.)"
echo "  ✓ JetBrainsMono Nerd Font"
echo ""
echo "Oh My Zsh plugins installed:"
echo "  ✓ zsh-completions"
echo "  ✓ zsh-syntax-highlighting"
echo "  ✓ zsh-autosuggestions"
echo "  ✓ k (enhanced directory listings)"
echo ""
echo "Configuration files copied:"
echo "  ✓ ~/.zshrc"
echo "  ✓ ~/.config/starship.toml"
echo "  ✓ ~/.config/zsh/"
echo "  ✓ ~/.config/nvim/ (LazyVim)"
echo ""
echo "Next steps:"
echo "  1. Close and reopen your terminal (or run: exec zsh)"
echo "  2. Set your terminal font to 'JetBrainsMono Nerd Font'"
echo "  3. Run 'nvim' - LazyVim will automatically install plugins on first launch"
echo "  4. Run 'tldr --update' to update tldr cache"
echo ""
echo "Useful commands:"
echo "  tldr <command>  - Quick command examples"
echo "  btop            - System monitor"
echo "  ncdu            - Disk usage analyzer"
echo "  duf             - Better df"
echo ""