#!/bin/bash
# LazyVim starter config for Neovim. OS-agnostic (plain git clone), plus the
# one keymap file this repo overlays on top of it.
# Depends on shared/lib/{log,backup}.sh.

install_lazyvim() {
    local shared_dir
    shared_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"

    if [ -d "$HOME/.config/nvim" ]; then
        log_success "~/.config/nvim already present — skipping LazyVim clone"
    else
        log_info "Installing LazyVim starter config..."
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
        log_success "LazyVim installed"
        log_info "Tip: run 'nvim', then ':LazyExtras' to enable lang.java / docker extras if needed"
    fi

    # Deliberately outside the branch above: the starter is left to upstream,
    # but this overlay must land on re-runs too, not just the first install.
    # The starter's own keymaps.lua is a comment-only placeholder, so there is
    # nothing of theirs to preserve by replacing it.
    link_file "$shared_dir/nvim/lua/config/keymaps.lua" \
        "$HOME/.config/nvim/lua/config/keymaps.lua"
}
