#!/bin/bash
# Starship prompt installer. OS-agnostic. Depends on shared/lib/log.sh.

install_starship() {
    if command -v starship >/dev/null 2>&1; then
        log_success "Starship already installed"
    else
        log_info "Installing Starship prompt..."
        # --yes: the upstream installer asks "Install Starship latest for
        # <target>? [y/n]" by default. Piped through `sh` there's no tty for
        # that prompt to read from, so without --yes this can hang forever
        # under a non-interactive invocation.
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        log_success "Starship installed"
    fi
}
