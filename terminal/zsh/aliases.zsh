# ===============================
# Modern Unix Replacements
# ===============================
alias please='sudo'
alias cd='z'
alias wp='cd /home/$USER/code && ls'

# Note: On Fedora, bat is called 'bat' (not 'batcat' like on Ubuntu)
alias cat='bat'
alias grep='rg'
alias du='ncdu'
alias df='duf'
alias top='btop'

# ===============================
# Directory Navigation
# ===============================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ===============================
# Git Aliases
# ===============================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gst='git status'
alias glog='git log --oneline --graph --decorate'

# ===============================
# System Aliases
# ===============================
alias ls='eza --icons -l --sort=modified --git'
alias la='eza --icons -la --sort=modified --git'
alias ll='ls -alF'
alias l='ls -CF'
alias h='history'
alias c='clear'
alias q='exit'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Network aliases
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip="ip route get 1 | awk '{print \$7}'"

# System monitoring
alias psg='ps aux | grep'
alias topcpu='ps auxf | sort -nr -k 3 | head -10'
alias topmem='ps auxf | sort -nr -k 4 | head -10'

# Directory operations
alias md='mkdir -p'
alias rd='rmdir'
alias sizeof='du -sh'

# Fedora-specific aliases
# alias update='sudo dnf upgrade --refresh'
# alias install='sudo dnf install -y'
# alias remove='sudo dnf remove'
# alias search='dnf search'
# alias cleanup='sudo dnf autoremove && sudo dnf clean all'

# Ubuntu-specific aliases
alias update='sudo nala update && sudo nala upgrade'
alias install='sudo nala install'
alias remove='sudo nala remove'
alias search='nala search'
alias cleanup='sudo nala autoremove && sudo nala clean'

# PostgreSQL aliases
alias pgstart="pg_ctl -D ~/.local/share/postgres -l ~/.local/share/postgres/logfile start"
alias pgstop="pg_ctl -D ~/.local/share/postgres stop"
alias pgstatus="pg_ctl -D ~/.local/share/postgres status"
