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
alias ports='ss -tulanp'
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

# Editor aliases
alias zed='zeditor'

# Postgres aliases
alias pgstart="pg_ctl -D ~/.local/share/postgres -l logfile start"
alias pgstop="pg_ctl -D ~/.local/share/postgres stop"
alias pgstatus="pg_ctl -D ~/.local/share/postgres status"

# Fix Flatpak Apps not showing in menu
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:/usr/local/share:/usr/share"

# Fedora-specific aliases
alias update='omarchy-update'
