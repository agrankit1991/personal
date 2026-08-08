#!/bin/bash
# Arch package-manager wrappers: pacman, the paru AUR helper, and flatpak.
# Every desktop install.sh sources this to get a uniform install_pkg /
# install_aur / install_flatpak_app interface.
#
# Depends on shared/lib/log.sh.

# Full system upgrade. Call this once per script run, not per component —
# Arch should never be partially upgraded (mixing a stale base with fresh
# deps of a newly installed package risks library version mismatches).
sync_pacman() {
    log_info "Syncing package database and upgrading system..."
    sudo pacman -Syu --noconfirm
}

install_pkg() {
    log_info "Installing (pacman): $*"
    sudo pacman -S --needed --noconfirm "$@"
}

ensure_paru() {
    if command -v paru >/dev/null 2>&1; then
        log_success "paru already installed"
        return 0
    fi
    log_info "Installing paru (AUR helper)..."
    install_pkg base-devel
    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru-bin.git "$build_dir/paru-bin"
    (cd "$build_dir/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$build_dir"
    log_success "paru installed"
}

install_aur() {
    ensure_paru
    log_info "Installing (AUR via paru): $*"
    paru -S --needed --noconfirm "$@"
}

ensure_flatpak() {
    if ! command -v flatpak >/dev/null 2>&1; then
        install_pkg flatpak
    fi
    if ! flatpak remotes | grep -q flathub; then
        log_info "Adding flathub remote..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
}

install_flatpak_app() {
    local app_id="$1"
    if flatpak list --app | grep -q "$app_id"; then
        log_success "$app_id already installed (flatpak)"
    else
        flatpak install -y flathub "$app_id"
        log_success "$app_id installed (flatpak)"
    fi
}
