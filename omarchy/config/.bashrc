# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions below.
[[ -f ~/.config/bash/aliases.bash ]] && source ~/.config/bash/aliases.bash
[[ -f ~/.config/bash/exports.bash ]] && source ~/.config/bash/exports.bash
[[ -f ~/.config/bash/functions.bash ]] && source ~/.config/bash/functions.bash
[[ -f ~/.config/bash/dev-servers.bash ]] && source ~/.config/bash/dev-servers.bash

# enable syntax highlighting, auto completion, auto suggestion
source -- ~/.local/share/blesh/ble.sh
