#!/bin/bash
# Installs Oh My Zsh plus the four plugins shared/config/zsh/zshrc expects,
# and switches the login shell to zsh. Idempotent: safe to re-run on a box
# that already has all of this. OS-agnostic (curl + git only).
#
# Depends on shared/lib/log.sh.

_install_omz_plugin() {
    local name="$1" url="$2"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
    if [ -d "$dest" ]; then
        log_success "$name plugin already installed"
    else
        git clone --depth=1 "$url" "$dest"
        log_success "$name plugin installed"
    fi
}

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_success "Oh My Zsh already installed"
    else
        log_info "Installing Oh My Zsh..."
        # The upstream installer overwrites ~/.zshrc with its own default.
        # Preserve ours across it, and run non-interactively (RUNZSH=no) so
        # it can't stall the script waiting on a "switch shell now?" prompt.
        local had_zshrc=0
        if [ -f "$HOME/.zshrc" ]; then
            had_zshrc=1
            cp "$HOME/.zshrc" "$HOME/.zshrc.pre-omz"
        fi
        RUNZSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        if [ "$had_zshrc" -eq 1 ]; then
            mv "$HOME/.zshrc.pre-omz" "$HOME/.zshrc"
        fi
        log_success "Oh My Zsh installed"
    fi

    log_info "Installing Oh My Zsh plugins..."
    _install_omz_plugin zsh-completions https://github.com/zsh-users/zsh-completions
    _install_omz_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
    _install_omz_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
    _install_omz_plugin k https://github.com/supercrabtree/k

    if [ "$SHELL" != "$(command -v zsh)" ]; then
        log_info "Changing default shell to zsh (log out/in for it to take effect)..."
        chsh -s "$(command -v zsh)"
        log_success "Default shell changed to zsh"
    else
        log_success "zsh is already the default shell"
    fi
}
