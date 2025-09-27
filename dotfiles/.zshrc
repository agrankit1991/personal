# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions k)

source $ZSH/oh-my-zsh.sh


# Modern Unix replacements
alias gs='git status'
alias please='sudo'
alias ls='eza --icons  -l --sort=modified --git'
alias la='eza --icons  -la --sort=modified --git'
alias cd='z'
alias wp='cd /home/$USER/Developer && ls'

alias cat='bat'
alias find='fd'
alias grep='rg'
alias du='ncdu'
alias df='duf'
alias top='btop'

# Bat specific settings
export BAT_THEME="Dracula"
export BAT_STYLE="full"

# FD (find) settings
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"


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

export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"
