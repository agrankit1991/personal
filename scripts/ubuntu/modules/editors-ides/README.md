# LazyVim Module

This module installs LazyVim - a modern Neovim configuration framework with the latest Neovim version.

## What is LazyVim?

LazyVim is a Neovim setup powered by lazy.nvim to make it easy to customize and extend your config. Rather than having to choose between starting from scratch or using a pre-made distro, LazyVim offers the best of both worlds - the flexibility of a custom config and the ease of a distro.

## Installation Method

This setup uses the official installation methods:

### **Neovim Installation**
- Downloads latest Neovim from GitHub releases
- Installs to `/opt/nvim-linux-x86_64/`
- Automatically configures PATH in shell configuration
- Ensures compatibility with LazyVim requirements

### **LazyVim Installation**
- Follows the official LazyVim installation guide
- Uses the LazyVim starter template with excellent defaults
- No custom configurations - pure LazyVim experience
- Auto-installs required dependencies (git, make, unzip, gcc)

## Features Included

### 🚀 **Performance**
- Blazingly fast startup time with lazy loading
- Optimized plugin configuration
- Smart caching and compilation

### 📦 **Pre-configured Plugins**
- **Telescope** - Fuzzy finder for files, buffers, and more
- **Neo-tree** - Modern file explorer
- **Treesitter** - Advanced syntax highlighting and text objects
- **LSP** - Language Server Protocol support with nvim-lspconfig
- **Mason** - Manage LSP servers, DAP servers, linters, and formatters
- **Which-key** - Displays available keybindings
- **Gitsigns** - Git integration and signs
- **Comment.nvim** - Smart commenting
- **Autopairs** - Automatic bracket/quote pairing
- **Surround** - Manipulate surroundings (quotes, brackets, etc.)

### 🎨 **UI & Themes**
- Beautiful default theme (Tokyonight)
- Modern statusline and tabline
- Icons and syntax highlighting
- Smooth scrolling and animations

### ⚡ **Developer Experience**
- Intelligent code completion
- Built-in terminal integration
- Git workflow integration
- Project-wide search and replace
- Code formatting and linting

## Default Configuration

This setup uses LazyVim's excellent defaults without custom modifications:

### **Built-in Features**
- Sensible editor settings and options
- Modern keybindings with leader key (`<space>`)
- Beautiful UI with Tokyonight theme
- Smart indentation and search settings
- Clipboard integration and mouse support

### **Default Keymaps**
LazyVim comes with well-thought-out keybindings:
- `<leader>e` - File explorer (Neo-tree)
- `<leader>ff` - Find files (Telescope)
- `<leader>sg` - Live grep/search
- `<leader>gg` - LazyGit integration
- `<leader>xl` - Location list
- `<leader>xq` - Quickfix list

### **Plugin Ecosystem**
LazyVim includes essential plugins out of the box:
- Language servers and completion
- File navigation and search
- Git integration
- Code formatting and linting
- Terminal integration

## File Structure

```
modules/editors-ides/
├── functions/
│   └── lazyvim-setup.sh    # Complete LazyVim installation functions
└── README.md              # This file
```

After installation, LazyVim creates:
```
~/.config/nvim/             # LazyVim configuration
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto commands
│   │   ├── keymaps.lua     # Keybindings
│   │   ├── lazy.lua        # Plugin manager setup
│   │   └── options.lua     # Editor options
│   └── plugins/            # Plugin configurations
├── init.lua                # Entry point
└── lazyvim.json           # LazyVim settings
```

## Installation Process

1. **Neovim Installation**: Downloads and installs latest Neovim from GitHub releases
2. **PATH Configuration**: Adds Neovim to system PATH in shell configuration
3. **Dependency Check**: Installs required tools (git, make, unzip, gcc)
4. **Backup Handling**: Safely backs up existing Neovim configuration
5. **LazyVim Setup**: Clones official LazyVim starter template
6. **Plugin Installation**: Automatically installs all plugins in headless mode
7. **Completion Info**: Shows getting started guide and essential commands

## Getting Started

After installation, launch Neovim with:
```bash
nvim
```

### Essential Commands
- `<space>` - Show available keybindings (Which-key)
- `:Lazy` - Plugin manager
- `:Mason` - Install LSP servers, formatters, linters
- `:checkhealth` - Verify Neovim health
- `:LazyExtras` - Browse additional plugin sets

### Default LazyVim Keybindings
- `<leader>e` - Toggle file explorer (Neo-tree)
- `<leader><space>` or `<leader>ff` - Find files (Telescope)
- `<leader>sg` - Live grep/search in project
- `<leader>fr` - Recent files
- `<leader>gg` - LazyGit (if installed)
- `<leader>xl` - Location list (diagnostics)
- `<leader>xq` - Quickfix list
- `<c-/>` - Toggle terminal
- `]d` / `[d` - Navigate diagnostics
- `gd` - Go to definition
- `gr` - Find references

## Installation Locations

### **Neovim**
- **Binary**: `/opt/nvim-linux-x86_64/bin/nvim`
- **Installation**: `/opt/nvim-linux-x86_64/`
- **PATH**: Added to shell configuration (~/.zshrc, ~/.bashrc)

### **LazyVim Configuration**
- **Main Config**: `~/.config/nvim/`
- **Plugin Data**: `~/.local/share/nvim/`
- **Cache**: `~/.cache/nvim/`
- **State**: `~/.local/state/nvim/`

## Troubleshooting

### First Startup is Slow
This is normal - plugins are being downloaded and compiled. Subsequent startups will be much faster.

### Plugin Issues
Run `:Lazy sync` to reinstall/update plugins.

### LSP Not Working
1. Run `:Mason` to install language servers
2. Check `:checkhealth` for issues
3. Ensure language servers are installed for your file types

### PATH Issues
If `nvim` command is not found after installation:
1. Restart your terminal
2. Manually source shell config: `source ~/.zshrc` or `source ~/.bashrc`
3. Check PATH: `echo $PATH | grep nvim`

### Configuration Changes Not Applied
1. Restart Neovim
2. Run `:Lazy reload` if needed
3. Check for syntax errors in configuration files

## Customization

LazyVim is designed to be easily customizable:

1. **Add Plugins**: Create files in `~/.config/nvim/lua/plugins/`
2. **Change Options**: Edit `~/.config/nvim/lua/config/options.lua`
3. **Add Keymaps**: Edit `~/.config/nvim/lua/config/keymaps.lua`
4. **Install Extras**: Use `:LazyExtras` to browse additional features
5. **Language Support**: Use `:Mason` to install language servers

### Example: Adding a Plugin
Create `~/.config/nvim/lua/plugins/example.lua`:
```lua
return {
  "plugin-author/plugin-name",
  config = function()
    -- Plugin configuration
  end,
}
```

## Requirements

- **Operating System**: Linux (x86_64 architecture)
- **Internet Connection**: Required for downloading Neovim and plugins
- **Dependencies**: git, make, unzip, gcc (auto-installed if missing)
- **Shell**: bash, zsh, or compatible shell

## Resources

- [LazyVim Documentation](https://www.lazyvim.org/)
- [LazyVim Installation Guide](https://www.lazyvim.org/installation)
- [Neovim Documentation](https://neovim.io/doc/)
- [Neovim GitHub Releases](https://github.com/neovim/neovim/releases)
- [Lua Guide for Neovim](https://github.com/nanotee/nvim-lua-guide)

## Notes

- **First Startup**: May be slower as plugins download and compile
- **Terminal Restart**: Required for PATH changes to take effect
- **Pure LazyVim**: Uses default configuration - no custom modifications
- **Easy Customization**: Add your own configurations as needed
- **Latest Versions**: Always installs the most recent Neovim and LazyVim