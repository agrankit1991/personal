#!/bin/bash
# "Terminal environment" component, shared by every Arch desktop script:
# modern CLI tools, Nerd Font, Neovim + LazyVim, mise, Starship, Oh My Zsh,
# and the shared dotfiles.
#
# Package lists live under shared/packages/ and arch/packages/, not inline
# here — see shared/lib/packages.sh.
#
# Depends on: shared/lib/{log,backup,packages}.sh, arch/lib/pacman.sh,
# and the shared/install-*.sh helpers (sourced by the calling install.sh).

install_terminal_component() {
    log_section "Terminal Environment"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/shared/packages/terminal.txt"
    local common_packages=("${PACKAGE_LIST[@]}")
    read_package_list "$repo_root/arch/packages/terminal-extra.txt"
    install_pkg "${common_packages[@]}" "${PACKAGE_LIST[@]}"

    read_package_list "$repo_root/arch/packages/terminal-fonts.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    install_mise
    install_starship
    install_lazyvim
    install_shared_dotfiles
    install_oh_my_zsh

    log_success "Terminal environment ready"
    log_info "Set your terminal font to 'JetBrainsMono Nerd Font' and run 'exec zsh' to pick it up"
}
