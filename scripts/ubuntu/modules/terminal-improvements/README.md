# Terminal Improvements Module

A modular system for setting up modern CLI tools, Oh My Zsh, and Zsh configuration.

## Structure

```
terminal-improvements/
├── functions/              # Modular function files
│   ├── cli-tools.sh       # CLI tools installation
│   ├── oh-my-zsh.sh       # Oh My Zsh framework setup
│   ├── powerlevel10k.sh   # Powerlevel10k theme setup
│   └── zsh-config.sh      # Zsh configuration management
├── templates/             # Configuration templates
│   ├── zshrc.template     # Main .zshrc template
│   ├── aliases.zsh.template    # Aliases configuration
│   ├── exports.zsh.template    # Environment variables
│   └── functions.zsh.template  # Custom functions
└── README.md             # This documentation
```

## Features

### 🔧 Modern CLI Tools
- **ripgrep (rg)** - Better grep with regex support
- **fd-find (fd)** - Better find command  
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colors and icons
- **zoxide** - Smart cd that learns your habits
- **duf** - Better df for disk usage
- **ncdu** - Interactive disk usage analyzer
- **fzf** - Fuzzy finder for files and commands
- **tldr** - Simplified man pages
- **tree** - Directory structure viewer
- **htop** - Interactive process viewer

### 🚀 Zsh Enhancement
- **Oh My Zsh** framework installation
- **Powerlevel10k** theme with existing configuration
- **Modular configuration** system
- **Essential plugins**:
  - zsh-completions
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - k (directory listing with git info)

### 📁 Modular Configuration
Creates a clean, maintainable Zsh setup:
- `~/.zshrc` - Main configuration (minimal)
- `~/.config/zsh/aliases.zsh` - Command aliases
- `~/.config/zsh/exports.zsh` - Environment variables
- `~/.config/zsh/functions.zsh` - Custom functions
- `~/.p10k.zsh` - Powerlevel10k configuration (copied from dotfiles)

## Usage

Run the main script:
```bash
./terminal-improvements-new.sh
```

## Functions Overview

### cli-tools.sh
- `install_cli_tools()` - Install modern CLI replacements
- `show_terminal_tips()` - Display usage tips and pro tips

### oh-my-zsh.sh  
- `install_oh_my_zsh()` - Install Oh My Zsh framework
- `install_oh_my_zsh_plugins()` - Install essential plugins

### powerlevel10k.sh
- `install_powerlevel10k_theme()` - Install theme
- `setup_powerlevel10k_config()` - Copy existing configuration

### zsh-config.sh
- `setup_modular_zsh_config()` - Create modular configuration
- `setup_shell_aliases()` - Legacy compatibility function

## Templates

All Zsh configuration files are generated from templates, making them:
- **Maintainable** - Easy to modify without touching the main script
- **Version controlled** - Templates can be tracked in git
- **Customizable** - Users can modify templates before installation
- **Consistent** - Same configuration every time

## Benefits

1. **Modularity** - Each component is in its own file
2. **Maintainability** - Easy to update individual parts
3. **Readability** - Clear separation of concerns
4. **Reusability** - Functions can be used independently
5. **Testability** - Individual functions can be tested in isolation
6. **Extensibility** - New features can be added easily

## Migration

To use this modular version instead of the monolithic script:
1. The main entry point is now `terminal-improvements-new.sh`
2. All functionality remains the same
3. Configuration templates can be customized before installation
4. Individual functions can be sourced and used independently