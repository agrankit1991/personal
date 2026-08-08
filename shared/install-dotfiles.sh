#!/bin/bash
# Installs the cross-platform terminal dotfiles (zsh config, Starship,
# Ghostty, fastfetch) from shared/config into $HOME. Identical on every OS —
# these are plain file copies, no package manager involved.
#
# Meant to be sourced by an OS-specific "terminal" component after it has
# installed the CLI tools these configs assume (zsh, starship, eza, etc).
# Depends on shared/lib/log.sh and shared/lib/backup.sh.

install_shared_dotfiles() {
    local shared_dir
    shared_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"

    log_info "Installing shared dotfiles..."
    install_file "$shared_dir/zshrc" "$HOME/.zshrc"
    install_file "$shared_dir/starship.toml" "$HOME/.config/starship.toml"
    install_dir "$shared_dir/zsh" "$HOME/.config/zsh"
    install_dir "$shared_dir/ghostty" "$HOME/.config/ghostty"
    install_dir "$shared_dir/fastfetch" "$HOME/.config/fastfetch"
}
