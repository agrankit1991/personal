#!/bin/bash
# "Dev tools" component: Docker + mise-managed language toolchains
# (Java, Node, Gradle — see shared/install-mise.sh for the version list).
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh,
# shared/install-mise.sh.

install_dev_tools_component() {
    log_section "Development Tools"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/dev-tools.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    install_mise
    install_mise_tools

    if systemctl is-active --quiet docker; then
        log_success "Docker service already running"
    else
        log_info "Enabling and starting docker service..."
        sudo systemctl enable --now docker.service
        log_success "Docker service enabled and started"
    fi

    if id -nG "$USER" | grep -qw docker; then
        log_success "User '$USER' already in the docker group"
    else
        sudo usermod -aG docker "$USER"
        log_success "User added to the docker group"
        log_warn "Log out and back in (or run 'newgrp docker') for this to take effect"
    fi

    log_success "Development tools ready"
}
