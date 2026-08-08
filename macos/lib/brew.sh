#!/bin/bash
# Homebrew bootstrap + package/cask install wrappers — the macOS counterpart
# to arch/lib/pacman.sh, exposing the same install_pkg/install_cask
# interface shape so components read the same way on both platforms.
#
# Depends on: shared/lib/log.sh.

# Homebrew's own installer needs a compiler toolchain; without this it fails
# with a confusing error rather than a clear "install Xcode CLT first".
# `xcode-select --install` only *launches* an async GUI installer and
# returns immediately, so we can't just wait — tell the user and stop.
ensure_xcode_command_line_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        log_success "Xcode Command Line Tools already installed"
        return 0
    fi
    log_info "Launching Xcode Command Line Tools installer..."
    xcode-select --install
    log_warn "Complete the Command Line Tools install in the popup that just" \
        "appeared, then re-run this script."
    exit 0
}

ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew already installed"
        return 0
    fi
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    log_success "Homebrew installed"
}

install_pkg() {
    log_info "Installing (brew): $*"
    brew install "$@"
}

install_cask() {
    log_info "Installing (brew --cask): $*"
    brew install --cask "$@"
}
