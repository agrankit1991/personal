# Fedora Setup Scripts

A modular setup system for Fedora development environment. This collection of scripts helps you set up a complete development environment on Fedora with ease.

## Features

- ✅ **Modular Design**: Each component is a separate module that can be run independently
- ✅ **Interactive**: Asks for confirmation before installing each tool
- ✅ **Smart Detection**: Checks if apps are already installed (DNF or Flatpak)
- ✅ **Flatpak First**: Uses Flatpak for GUI applications when possible
- ✅ **DNF for System**: Uses DNF for system packages and CLI tools
- ✅ **No Snap**: Uses Flatpak instead of Snap for universal packages
- ✅ **RPM Fusion**: Optional support for RPM Fusion repositories

## Prerequisites

- Fedora Linux (tested on Fedora 38+)
- Internet connection
- Regular user account with sudo privileges

## Quick Start

1. Clone or download this repository
2. Navigate to the fedora directory:
   ```bash
   cd scripts/fedora
   ```
3. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```
4. Run the setup script:
   ```bash
   ./setup.sh
   ```

## Modules

### 1. System Update & RPM Fusion
- Updates system packages
- Optionally enables RPM Fusion repositories (Free and Non-Free)
- Updates package cache

### 2. Essential Packages
- System essentials (curl, wget, git, btop, tree, flatpak)
- Build tools (gcc, make, cmake, pkg-config)
- Compression tools (zip, unzip, tar, 7zip)
- Multimedia tools (ffmpeg)
- Text processing (jq, vim)
- Network tools (net-tools, bind-utils)
- Fastfetch (system information tool)
- Flatpak and Flathub setup
- Firewall configuration

### 3. Git Configuration
- Configure Git user information
- Set up recommended Git settings
- Create useful Git aliases
- View current Git configuration

### 4. Terminal Improvements
- Modern CLI tools:
  - ripgrep (better grep)
  - fd-find (better find)
  - bat (better cat)
  - eza (better ls)
  - zoxide (smart cd)
  - duf (better df)
  - ncdu (disk usage analyzer)
  - fzf (fuzzy finder)
  - tldr (simplified man pages)
  - htop (process viewer)
- Oh My Zsh framework
- Zsh plugins (autosuggestions, syntax highlighting)
- Powerlevel10k theme
- Zsh as default shell

### 5. Browsers
All browsers installed via Flatpak:
- Firefox
- Google Chrome
- Brave
- Chromium
- Opera
- Vivaldi
- Microsoft Edge

### 6. Development Languages
- **Python**: Python 3, pip, virtualenv, poetry
- **Node.js**: Via DNF or NVM
- **Java**: Via DNF or SDKMAN
- **Go**: Via DNF
- **Rust**: Via rustup
- **Docker**: Official Docker CE
- **Others**: PHP, Ruby, Perl

### 7. Editors and IDEs
Terminal editors:
- Vim (enhanced)
- Neovim (with optional LazyVim)
- Emacs
- Nano

GUI editors (via Flatpak):
- Visual Studio Code
- VSCodium
- Sublime Text
- GNOME Text Editor
- Kate

IDEs (via Flatpak):
- IntelliJ IDEA Community
- PyCharm Community
- Eclipse
- Android Studio
- JetBrains Toolbox

### 8. Database Tools
Servers:
- PostgreSQL (with initialization)
- MariaDB/MySQL (with secure setup)
- Redis
- MongoDB
- SQLite

GUI tools (via Flatpak):
- DBeaver Community

CLI tools:
- psql (PostgreSQL client)
- mysql/mariadb client
- redis-cli

### 9. Other Applications

Productivity (via Flatpak):
- LibreOffice
- GNOME Calendar
- GNOME Contacts
- Evince (Document Viewer)
- Thunderbird

Communication (via Flatpak):
- Slack
- Discord
- Zoom
- Microsoft Teams
- Telegram

Media (via Flatpak):
- VLC
- Spotify
- Audacity
- GIMP
- Inkscape
- Blender

Utilities (via Flatpak):
- GNOME Calculator
- Archive Manager
- Flatseal (Flatpak permissions)
- Warehouse (Flatpak manager)

Additional:
- Multimedia codecs (from RPM Fusion)
- Virtualization tools (QEMU/KVM, virt-manager)
- VirtualBox (from RPM Fusion)

### 10. System Cleanup
- Clean DNF cache
- Remove unused packages
- Remove old kernels (keep latest 3)
- Clean Flatpak unused runtimes
- Clean journal logs
- Clean temporary files
- Clean user cache

## Architecture

```
fedora/
├── setup.sh              # Main entry point
├── lib/
│   ├── colors.sh        # Color definitions
│   └── utils.sh         # Utility functions
└── modules/
    ├── system-update.sh
    ├── essential-packages.sh
    ├── git-config.sh
    ├── terminal-improvements.sh
    ├── browsers.sh
    ├── dev-languages.sh
    ├── editors-ides.sh
    ├── database-tools.sh
    ├── other-apps.sh
    └── system-cleanup.sh
```

## Utility Functions

The `lib/utils.sh` file provides common functions used across all modules:

### Package Management
- `dnf_package_installed(package)` - Check if DNF package is installed
- `flatpak_app_installed(app_id)` - Check if Flatpak app is installed
- `is_app_installed(app_name, flatpak_id)` - Check if app is installed (DNF or Flatpak)
- `install_dnf_package(package, description)` - Install DNF package with confirmation
- `install_flatpak_app(app_id, app_name)` - Install Flatpak app with confirmation
- `setup_flathub()` - Setup Flathub repository
- `enable_rpmfusion()` - Enable RPM Fusion repositories

### System Utilities
- `command_exists(command)` - Check if command exists
- `is_root()` - Check if running as root
- `is_fedora()` - Check if system is Fedora
- `get_fedora_version()` - Get Fedora version number
- `check_internet()` - Check internet connectivity

### User Interface
- `confirm(message, default)` - Prompt for yes/no confirmation
- `box(text)` - Draw a box around text
- `simple_header(text)` - Create a simple header
- `show_progress(message)` - Show progress indicator
- `show_success(message)` - Show success message
- `show_error(message)` - Show error message
- `show_warning(message)` - Show warning message

### File Operations
- `backup_file(file)` - Backup file with timestamp
- `ensure_dir(directory)` - Create directory if it doesn't exist
- `download_file(url, output, description)` - Download file with progress
- `add_line_to_file(line, file)` - Add line to file if it doesn't exist
- `remove_line_from_file(pattern, file)` - Remove line from file

## Differences from Ubuntu Version

1. **Package Manager**: Uses DNF instead of apt/nala
2. **No Snap**: Uses Flatpak exclusively for universal packages
3. **RPM Fusion**: Uses RPM Fusion instead of PPAs for additional software
4. **Database Initialization**: PostgreSQL and MariaDB require different setup steps
5. **Service Management**: Uses systemctl for all service management
6. **Default Software**: Some Fedora-specific defaults (e.g., MariaDB instead of MySQL)

## Tips

- Run modules in order (1-10) for best results
- Essential Packages (module 2) should be run before most other modules
- Each module asks for confirmation before installing each tool
- You can run modules multiple times - they check if tools are already installed
- All installations can be interrupted safely with Ctrl+C

## Troubleshooting

### Flatpak apps not showing up
- Run: `flatpak update`
- Log out and log back in

### DNF is slow
- Check internet connection
- Try: `sudo dnf clean all && sudo dnf makecache`

### Permission errors
- Don't run the script as root
- Make sure your user has sudo privileges

### RPM Fusion packages not found
- Run module 1 (System Update & RPM Fusion) first
- Enable RPM Fusion when prompted

## Contributing

Feel free to add more modules or improve existing ones. Follow the existing structure:

1. Create a new script in `modules/`
2. Source the utilities: `source "$LIB_DIR/utils.sh"`
3. Use the utility functions for consistency
4. Add error checking and user confirmations
5. Update this README

## License

This project is provided as-is for personal use.

## Author

Created for easy Fedora development environment setup.
