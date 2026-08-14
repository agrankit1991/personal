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
    # Build the source `paru` package, NOT `paru-bin` (or its -debug
    # sibling) — the prebuilt binaries have proven unreliable here, so the
    # few minutes of Rust compile time buy a helper that actually works.
    # makepkg -s pulls in the cargo/rust makedep from the official repos on
    # its own, which also means it leaves an existing rustup install alone
    # instead of fighting it over the `rust` package.
    log_info "Installing paru (AUR helper) — built from source, takes a few minutes..."
    install_pkg base-devel git
    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
    (cd "$build_dir/paru" && makepkg -si --noconfirm)
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
