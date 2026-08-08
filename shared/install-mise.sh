#!/bin/bash
# mise (polyglot version manager) install + language toolchain setup.
# OS-agnostic: the installer and `mise use` both work identically on Linux
# and macOS. Tool versions live in shared/packages/mise-tools.txt.
#
# Depends on: shared/lib/{log,packages}.sh.

install_mise() {
    if command -v mise >/dev/null 2>&1 || [ -x "$HOME/.local/bin/mise" ]; then
        log_success "mise already installed"
    else
        log_info "Installing mise..."
        curl -fsSL https://mise.run | sh
        log_success "mise installed"
    fi
}

install_mise_tools() {
    local mise_bin="$HOME/.local/bin/mise"
    command -v mise >/dev/null 2>&1 && mise_bin="mise"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    read_package_list "$repo_root/shared/packages/mise-tools.txt"

    local tool_spec tool version
    for tool_spec in "${PACKAGE_LIST[@]}"; do
        tool="${tool_spec%%@*}"
        version="${tool_spec##*@}"
        if "$mise_bin" ls "$tool" 2>/dev/null | grep -q "$version"; then
            log_success "$tool_spec already installed"
        else
            "$mise_bin" use -g "$tool_spec"
            log_success "$tool_spec installed and set as global default"
        fi
    done
}
