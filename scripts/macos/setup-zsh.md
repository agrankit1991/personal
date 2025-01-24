# Complete macOS Shell and iTerm2 Setup Guide

## 1. Install iTerm2

```bash
# Install iTerm2 using Homebrew
brew install --cask iterm2
```

## 2. Install Oh My Zsh

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## 3. Install Powerlevel10k Theme

```bash
# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install recommended font
brew install --cask font-meslo-lg-nerd-font
```

## 4. Install Essential Plugins

```bash
# Install Zsh plugins
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
```

## 5. Configure Zsh

Create/edit your `.zshrc`:
```bash
# Create backup of existing .zshrc
cp ~/.zshrc ~/.zshrc.backup

# Create new .zshrc
cat > ~/.zshrc << 'EOL'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions k z)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='code'


# Modern Unix replacements
alias gs='git status'
alias please='sudo'
alias ls='eza --icons --group-directories-first -l --sort=modified --reverse'
alias cd='z'
alias wp='cd /home/$USER/Developer && ls'

alias cat='bat'
alias find='fd'
alias grep='rg'
alias du='ncdu'
alias df='duf'
alias top='htop'

# Bat specific settings
export BAT_THEME="Dracula"
export BAT_STYLE="full"

# FD (find) settings
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# Hide brew hints
export HOMEBREW_NO_ENV_HINTS=1

# Directory shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Load custom functions
function mcd() {
  mkdir -p "$@" && cd "$_"
}

# Quick find
function f() {
  find . -name "*$1*"
}

function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL
```

## 6. Configure iTerm2

### Color Scheme Setup
1. Download Snazzy color scheme:
```bash
curl -L https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Snazzy.itermcolors > ~/Downloads/Snazzy.itermcolors
```

### iTerm2 Preferences

Open iTerm2 and configure:

1. **General Settings**:
```
Preferences → General
- Closing → Confirm "Quit iTerm2" Command: Enable
- Window → Smart Window Placement: Enable
- Selection → Applications in terminal may access clipboard: Enable
```

2. **Appearance Settings**:
```
Preferences → Appearance
- Theme: Minimal
- Tab bar location: Top
- Status bar location: Bottom
```

3. **Profile Settings**:
```
Preferences → Profiles → Default
- General
  * Working Directory: Reuse previous session's directory
- Colors
  * Import Snazzy theme
- Text
  * Font: MesloLGM NF
  * Size: 12
- Window
  * Transparency: 10
  * Blur: Enable
- Terminal
  * Scrollback lines: 10000
```

4. **Key Mappings**:
```
Preferences → Keys → Key Bindings
Add:
- ⌘← - Send Hex Code: 0x01 (Go to beginning of line)
- ⌘→ - Send Hex Code: 0x05 (Go to end of line)
- ⌥← - Send Escape Sequence: b (Move back one word)
- ⌥→ - Send Escape Sequence: f (Move forward one word)
```