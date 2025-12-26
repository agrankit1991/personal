# ===============================
# Modern Unix Replacements
# ===============================
alias please='sudo'
alias cd='z'
alias wp='cd /home/$USER/code && ls'

# On Arch, the binary is 'bat'
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

# ===============================
# Arch-Specific Aliases (Pacman)
# ===============================
# If using 'yay' or 'paru', replace 'sudo pacman' with your helper
alias update='sudo pacman -Syu'
alias install='sudo pacman -S --needed'
alias remove='sudo pacman -Rs'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)' # Removes unused dependencies (orphans)
alias mirror='sudo reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# ===============================
# PostgreSQL Aliases
# ===============================
alias pgstart="pg_ctl -D ~/.local/share/postgres -l logfile start"
alias pgstop="pg_ctl -D ~/.local/share/postgres stop"
alias pgstatus="pg_ctl -D ~/.local/share/postgres status"
