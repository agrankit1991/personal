#!/bin/bash
# "Dev tools" component for macOS: Docker Desktop + mise-managed language
# toolchains (Java, Node, Gradle — see shared/install-mise.sh).
#
# Depends on: shared/lib/{log,packages}.sh, macos/lib/brew.sh,
# shared/install-mise.sh.

install_dev_tools_component() {
    log_section "Development Tools"

    if [ -d "/Applications/Docker.app" ]; then
        log_success "Docker Desktop already installed"
    else
        local repo_root
        repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
        read_package_list "$repo_root/macos/packages/dev-tools-casks.txt"
        install_cask "${PACKAGE_LIST[@]}"
    fi

    install_mise
    install_mise_tools

    log_success "Development tools ready"
    log_info "Docker Desktop must be started manually the first time (Spotlight > Docker)"
}
