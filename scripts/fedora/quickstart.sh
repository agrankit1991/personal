#!/bin/bash

# Quick Start Guide for Fedora Setup Scripts
# This script provides a guided tour through the setup process

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Fedora Setup Scripts - Quick Start Guide              ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo
echo -e "${GREEN}Welcome to the Fedora Setup Scripts!${NC}"
echo
echo "This guide will help you get started with setting up your Fedora system."
echo
echo -e "${YELLOW}Prerequisites:${NC}"
echo "  ✓ Fedora Linux (38 or newer)"
echo "  ✓ Internet connection"
echo "  ✓ User account with sudo privileges"
echo
echo -e "${YELLOW}What this will do:${NC}"
echo "  • Set up a complete development environment"
echo "  • Install modern CLI tools"
echo "  • Configure Git"
echo "  • Install browsers, editors, IDEs"
echo "  • Set up databases"
echo "  • Install productivity apps"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Recommended Installation Order${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo "For the best experience, run the modules in this order:"
echo
echo "1. System Update & RPM Fusion"
echo "   └─ Updates your system and optionally enables RPM Fusion"
echo
echo "2. Essential Packages"
echo "   └─ Installs core tools like git, flatpak, build tools"
echo
echo "3. Git Configuration"
echo "   └─ Sets up your Git identity and preferences"
echo
echo "4. Terminal Improvements"
echo "   └─ Installs modern CLI tools and Oh My Zsh"
echo
echo "5. Development Languages"
echo "   └─ Installs Python, Node.js, Java, Go, Rust, Docker"
echo
echo "6. Editors and IDEs"
echo "   └─ Installs Vim, Neovim, VS Code, IntelliJ, etc."
echo
echo "7. Browsers"
echo "   └─ Installs Firefox, Chrome, Brave, etc. via Flatpak"
echo
echo "8. Database Tools"
echo "   └─ Installs PostgreSQL, MariaDB, Redis, MongoDB"
echo
echo "9. Other Applications"
echo "   └─ Productivity, communication, and media apps"
echo
echo "10. System Cleanup"
echo "    └─ Cleans up caches and unused packages"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Important Notes${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}Package Managers:${NC}"
echo "  • DNF - For system packages and CLI tools"
echo "  • Flatpak - For GUI applications"
echo "  • No Snap - We use Flatpak instead"
echo
echo -e "${YELLOW}RPM Fusion:${NC}"
echo "  • Optional but recommended for:"
echo "    - Multimedia codecs"
echo "    - VirtualBox"
echo "    - Non-free software"
echo
echo -e "${YELLOW}Interactive Installation:${NC}"
echo "  • Each tool asks for confirmation"
echo "  • Already installed? It will skip"
echo "  • Safe to run multiple times"
echo
echo -e "${YELLOW}Time Required:${NC}"
echo "  • Quick setup: 15-30 minutes"
echo "  • Full setup: 1-2 hours (depending on selections)"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Running the Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo "To start the setup, run:"
echo
echo -e "${YELLOW}  ./setup.sh${NC}"
echo
echo "You'll see a menu like this:"
echo
echo "  ╔════════════════════════════════════════════════════════════╗"
echo "  ║  Fedora Setup Script - Modular Development Environment    ║"
echo "  ╚════════════════════════════════════════════════════════════╝"
echo
echo "   1.  System Update & RPM Fusion"
echo "   2.  Install Essential Packages"
echo "   3.  Setup Git Configuration"
echo "   ..."
echo "   q.  Exit"
echo
echo "Simply enter the number of the module you want to run."
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Example Usage${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}Scenario 1: Fresh Fedora Installation${NC}"
echo
echo "1. Run modules 1-2 first (System Update + Essentials)"
echo "2. Then run module 3-4 (Git + Terminal)"
echo "3. Install what you need (languages, editors, etc.)"
echo "4. Run module 10 when done (cleanup)"
echo
echo -e "${YELLOW}Scenario 2: Just Need Development Tools${NC}"
echo
echo "1. Skip to module 5 (Development Languages)"
echo "2. Run module 6 (Editors and IDEs)"
echo "3. Run module 8 if you need databases"
echo
echo -e "${YELLOW}Scenario 3: Install Specific App${NC}"
echo
echo "1. Run the relevant module"
echo "2. Answer 'n' to skip apps you don't want"
echo "3. Answer 'y' only for what you need"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Troubleshooting Tips${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}If something goes wrong:${NC}"
echo
echo "1. Check your internet connection"
echo "   └─ Run: ping -c 3 google.com"
echo
echo "2. Update DNF cache"
echo "   └─ Run: sudo dnf clean all && sudo dnf makecache"
echo
echo "3. Check if RPM Fusion is needed"
echo "   └─ Some packages require RPM Fusion"
echo
echo "4. Flatpak apps not showing?"
echo "   └─ Log out and log back in"
echo
echo "5. Permission errors?"
echo "   └─ Don't run as root, use sudo when needed"
echo
echo "6. Service won't start?"
echo "   └─ Check: sudo systemctl status service-name"
echo "   └─ Check logs: sudo journalctl -xe"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}After Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}Terminal Improvements:${NC}"
echo "  • Restart terminal or run: exec zsh"
echo "  • Configure Powerlevel10k: p10k configure"
echo
echo -e "${YELLOW}Docker:${NC}"
echo "  • Log out and back in if added to docker group"
echo "  • Test with: docker run hello-world"
echo
echo -e "${YELLOW}Databases:${NC}"
echo "  • Services are enabled and running"
echo "  • PostgreSQL: sudo -u postgres psql"
echo "  • MariaDB: sudo mysql"
echo
echo -e "${YELLOW}Flatpak Apps:${NC}"
echo "  • Find in application menu"
echo "  • Or run: flatpak run app.id"
echo
echo -e "${YELLOW}System Cleanup:${NC}"
echo "  • Run module 10 periodically to clean up"
echo
read -p "Press Enter to continue..."
clear

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Useful Commands${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo
echo -e "${YELLOW}DNF Commands:${NC}"
echo "  sudo dnf upgrade              # Update all packages"
echo "  sudo dnf search <package>     # Search for package"
echo "  sudo dnf info <package>       # Show package info"
echo "  sudo dnf remove <package>     # Remove package"
echo "  dnf list installed            # List installed packages"
echo
echo -e "${YELLOW}Flatpak Commands:${NC}"
echo "  flatpak search <app>          # Search for app"
echo "  flatpak install <app-id>      # Install app"
echo "  flatpak list --app            # List installed apps"
echo "  flatpak uninstall <app-id>    # Remove app"
echo "  flatpak update                # Update all apps"
echo
echo -e "${YELLOW}System Management:${NC}"
echo "  sudo systemctl status <svc>   # Check service status"
echo "  sudo systemctl start <svc>    # Start service"
echo "  sudo systemctl enable <svc>   # Enable at boot"
echo "  sudo journalctl -xe           # View system logs"
echo
read -p "Press Enter to start setup..."
clear

echo -e "${GREEN}Starting setup script...${NC}"
echo
sleep 1

# Run the actual setup script
./setup.sh
