#!/bin/bash
# "GUI apps" component, shared by every Arch desktop script: general-purpose
# dev/desktop apps that aren't tied to any particular DE.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_apps_component() {
    log_section "GUI Apps"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/arch/packages/apps.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    read_package_list "$repo_root/arch/packages/apps-aur.txt"
    install_aur "${PACKAGE_LIST[@]}"

    read_package_list "$repo_root/arch/packages/apps-flatpak.txt"
    local flatpak_apps=("${PACKAGE_LIST[@]}")
    ensure_flatpak
    local app_id
    for app_id in "${flatpak_apps[@]}"; do
        install_flatpak_app "$app_id"
    done

    # Editor settings. These live in shared/config/ because the content is
    # cross-platform, but the destinations are not (macOS puts both under
    # ~/Library/Application Support/), so they're installed here per OS
    # rather than by install-dotfiles.sh. The link target keeps the .jsonc
    # extension while the link itself is the .json name each editor looks for.
    #
    # Unlike the hand-edited configs, both editors write this file back when
    # you change a setting through their UI. That is the point of linking them
    # — the change lands in the repo instead of being silently overwritten on
    # the next install — but it does mean the editor, not you, owns the
    # formatting of anything it rewrites, so check `git diff` before
    # committing rather than assuming the comment blocks survived intact.
    link_file "$repo_root/shared/config/zed/settings.jsonc" \
        "$HOME/.config/zed/settings.json"
    link_file "$repo_root/shared/config/vscode/settings.jsonc" \
        "$HOME/.config/Code/User/settings.json"

    log_success "GUI apps ready"
    log_info "Optional OpenCode setup: run 'opencode init' to configure API keys"
}
