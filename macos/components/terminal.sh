#!/bin/bash
# "Terminal environment" component for macOS — same shared dotfiles as
# Arch, via Homebrew instead of pacman. Every formula this needs is already
# in shared/packages/terminal.txt (identical names on brew and pacman); the
# cask list here is macOS-only (fonts + terminal emulator).
#
# Depends on: shared/lib/{log,backup,packages}.sh, macos/lib/brew.sh,
# and the shared/install-*.sh helpers (sourced by the calling install.sh).

install_terminal_component() {
    log_section "Terminal Environment"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/shared/packages/terminal.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/macos/packages/terminal-casks.txt"
    install_cask "${PACKAGE_LIST[@]}"

    install_mise
    install_starship
    install_lazyvim
    install_shared_dotfiles
    install_oh_my_zsh

    log_success "Terminal environment ready"
    log_info "Set your terminal font to 'JetBrainsMono Nerd Font' and run 'exec zsh' to pick it up"
}
