#!/bin/bash
# LazyVim starter config for Neovim. OS-agnostic (plain git clone).
# Depends on shared/lib/log.sh.

install_lazyvim() {
    if [ -d "$HOME/.config/nvim" ]; then
        log_success "~/.config/nvim already present — skipping LazyVim clone"
        return 0
    fi
    log_info "Installing LazyVim starter config..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    log_success "LazyVim installed"
    log_info "Tip: run 'nvim', then ':LazyExtras' to enable lang.java / docker extras if needed"
}
