# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to Powerlevel10k
ZSH_THEME=""

# Set plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions k fzf)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source modular configuration files
[[ -f ~/.config/zsh/aliases.zsh ]] && source ~/.config/zsh/aliases.zsh
[[ -f ~/.config/zsh/exports.zsh ]] && source ~/.config/zsh/exports.zsh
[[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh
[[ -f ~/.config/zsh/dev-servers.zsh ]] && source ~/.config/zsh/dev-servers.zsh

# Initialize zoxide (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

eval "$(starship init zsh)"
