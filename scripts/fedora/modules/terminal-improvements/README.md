# Terminal Improvements Module

This module installs modern CLI tools, Oh My Zsh framework, and terminal enhancements for Fedora.

## Structure

```
terminal-improvements/
├── functions/
│   ├── cli-tools.sh         # Modern CLI tools installation
│   ├── oh-my-zsh.sh         # Oh My Zsh framework and plugins
│   ├── powerlevel10k.sh     # Powerlevel10k theme
│   └── zsh-config.sh        # Modular Zsh configuration setup
└── templates/
    ├── zshrc.template            # Main .zshrc configuration
    ├── aliases.zsh.template      # Command aliases
    ├── exports.zsh.template      # Environment variables
    └── functions.zsh.template    # Custom shell functions
```

## What Gets Installed

### Modern CLI Tools (via DNF)
- **ripgrep** (rg) - Better grep with regex support
- **fd-find** (fd) - Better find command
- **bat** - Better cat with syntax highlighting
- **eza** - Better ls with colors and icons
- **zoxide** (z) - Smart cd that learns your habits
- **duf** - Better df for disk usage
- **ncdu** - Interactive disk usage analyzer
- **fzf** - Fuzzy finder for files and commands
- **tldr** - Simplified man pages
- **htop** - Interactive process viewer

### Zsh Framework & Plugins
- **Oh My Zsh** - Popular Zsh framework
- **Plugins:**
  - zsh-autosuggestions - Fish-like autosuggestions
  - zsh-syntax-highlighting - Syntax highlighting for commands
  - zsh-completions - Additional completion definitions
  - k - Enhanced directory listings with git info
  - fzf - Fuzzy finder integration

### Theme
- **Powerlevel10k** - Fast and customizable Zsh theme

### Configuration Files

The module creates a modular Zsh configuration:

#### ~/.zshrc (Main Configuration)
- Enables Powerlevel10k instant prompt
- Configures Oh My Zsh
- Loads all plugins
- Sources modular config files
- Initializes zoxide

#### ~/.config/zsh/aliases.zsh (Aliases)
- Modern tool aliases (bat, rg, eza, etc.)
- Git shortcuts
- Navigation helpers
- Safety aliases (rm -i, cp -i, mv -i)
- Fedora-specific aliases (update, install, cleanup)

#### ~/.config/zsh/exports.zsh (Environment Variables)
- Editor preferences (EDITOR, VISUAL)
- History settings
- Path modifications
- Tool configurations

#### ~/.config/zsh/functions.zsh (Custom Functions)
- `mcd()` - Create directory and cd into it
- `extract()` - Extract various archive formats
- `backup()` - Quick backup with timestamp
- `proj()` - Navigate to projects
- `gclone()` - Git clone and cd
- `update-system()` - Update Fedora and Flatpak
- `clean-system()` - Clean DNF and Flatpak
- And more...

## Usage

Run the terminal improvements module from the main setup script:

```bash
./setup.sh
# Select option 4: Setup Terminal Improvements
```

Or run it directly:

```bash
./modules/terminal-improvements.sh
```

## After Installation

1. **Restart Terminal** or run:
   ```bash
   exec zsh
   ```

2. **Configure Powerlevel10k**:
   ```bash
   p10k configure
   ```

3. **Try New Commands**:
   ```bash
   rg "search pattern"    # Instead of grep -r
   fd filename            # Instead of find
   bat file.txt           # Instead of cat
   eza -la                # Instead of ls -la
   z ~/projects           # Smart cd (after using directories)
   ```

## Customization

### Adding More Aliases

Edit `~/.config/zsh/aliases.zsh`:
```bash
alias myalias='mycommand'
```

### Adding Environment Variables

Edit `~/.config/zsh/exports.zsh`:
```bash
export MY_VAR="value"
```

### Adding Custom Functions

Edit `~/.config/zsh/functions.zsh`:
```bash
function myfunction() {
    # Your code here
}
```

### Modifying Plugins

Edit `~/.zshrc` and change the plugins line:
```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions k fzf your-plugin)
```

## Troubleshooting

### Oh My Zsh not found
- Ensure git is installed
- Check internet connection
- Run again - it will skip if already installed

### Zsh not default shell
- Run: `chsh -s $(which zsh)`
- Log out and log back in

### Powerlevel10k fonts not working
- Install a Nerd Font (e.g., MesloLGS NF)
- Configure your terminal to use the font
- Run `p10k configure` again

### Zoxide not working
- Restart terminal after installation
- Use directories first (cd to them)
- Then use `z dirname` to jump

## Differences from Ubuntu Version

1. **Package Manager**: Uses DNF instead of apt/nala
2. **bat**: Called `bat` (not `batcat`)
3. **Aliases**: Includes Fedora-specific aliases for dnf
4. **Functions**: Includes `update-system()` and `clean-system()` for Fedora

## Notes

- All installations ask for confirmation
- Already installed tools are detected and skipped
- Safe to run multiple times
- Configurations are backed up before modification
