# ===============================
# Environment Variables (Bash)
# ===============================

# FD (find) settings
export FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# Editor preference
# 'code' is VS Code. If you want Zed, change this to 'zeditor' or 'zed'
export EDITOR="code"
export VISUAL="code"

# ===============================
# History Settings (Bash Syntax)
# ===============================
# Bash uses different variable names than Zsh for history control
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTFILE=~/.bash_history

# Avoid duplicate entries and commands starting with space
export HISTCONTROL=ignoreboth:erasedups

# Append to history immediately (don't overwrite it)
shopt -s histappend

# Save multi-line commands as single history entries
shopt -s cmdhist

# ===============================
# Paths (Arch/Omarchy)
# ===============================
# Ensure local bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Less configuration
export LESS='-R --use-color'
