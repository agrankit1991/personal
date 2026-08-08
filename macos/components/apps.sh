#!/bin/bash
# "GUI apps" component for macOS — the cask equivalents of
# arch/components/apps.sh's package list.
#
# Depends on: shared/lib/{log,packages}.sh, macos/lib/brew.sh.

install_apps_component() {
    log_section "GUI Apps"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/macos/packages/apps-casks.txt"
    install_cask "${PACKAGE_LIST[@]}"

    log_success "GUI apps ready"
    log_info "OpenCode isn't in Homebrew as of this writing — install it manually from its own docs if you want it here"
}
