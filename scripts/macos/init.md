# macOS Developer Environment Setup Guide

## 1. Install Command Line Tools

First, install Xcode Command Line Tools:
```bash
xcode-select --install
```

## 2. Install Homebrew

Install the package manager Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add Homebrew to your PATH (for Apple Silicon Macs):
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 3. Set Up Git
Follow from Setup Git.md file

## 4. Install and Configure Shell (Zsh & Oh My Zsh)
Follow from Setup ZSH.md file

## 5. Create Developer Directory Structure

```bash
# Create main development directory
mkdir -p ~/Developer

# Create project-specific directories
mkdir -p ~/Developer/{Personal,Work,OpenSource,Learning,Archive}

# Create a directory for development tools and configurations
mkdir -p ~/Developer/Tools
mkdir -p ~/Developer/.config
```

## 6. Essential Development Tools

Install common development tools:
```bash
# Version managers
brew install nvm   # Node.js version manager
brew install rbenv # Ruby version manager
brew install pyenv # Python version manager

# Development tools
# Install Java
brew install openjdk@17    # For Java 17 LTS
# Add these to ~/.zshrc
# export JAVA_HOME=$(/usr/libexec/java_home)
# export PATH="$JAVA_HOME/bin:$PATH"

# Link the installed java
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Switch Java versions (if multiple installed)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)  # Switch to Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 11)  # Switch to Java 11

# Install Build tools
# Install Maven
brew install maven

# Install Gradle
brew install gradle

# brew install --cask iterm2 # It will be installed as part of zsh setup

# CLI tools
brew install eza        # Modern replacement for 'ls'
brew install bat        # Modern replacement for 'cat'
brew install fd         # Modern replacement for 'find'
brew install ripgrep    # Modern replacement for 'grep'
brew install tldr       # Simplified man pages
brew install tree       # Directory structure viewer
brew install jq         # JSON processor
brew install htop       # Modern process viewer
brew install ncdu       # Disk usage analyzer
brew install duf        # Disk usage viewer
brew install wget       # Utility for downloading files from the web
```


## Developer tools
```bash
brew install --cask visual-studio-code
brew install --cask intellij-idea-ce
brew install --cask docker
brew install --cask postman
brew install --cask dbeaver-community
brew install --cask firefox
brew install --cask google-chrome
brew install --cask tor-browser
```

## Other tools
```bash
brew install --cask 1password
brew install --cask discord
brew install --cask notion
brew install --cask kindle
brew install --cask obsidian
brew install --cask caffeine
brew install --cask alfred
brew install --cask vlc
brew install --cask tradingview
```

## Common .zshrc Aliases

Add these helpful aliases to your `~/.zshrc`:
```bash
# Git aliases
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'

# Directory navigation
alias dev='cd ~/Developer'
alias ..='cd ..'
alias ...='cd ../..'