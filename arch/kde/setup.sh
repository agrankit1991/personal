#!/bin/bash
# KDE Plasma desktop-specific setup: base Plasma packages, a music player
# (Elisa) + video player (Haruna) since neither ships with plasma-desktop,
# thumbnail generation support for Dolphin, and NumLock at both the login
# screen and inside the Plasma session.
#
# KDE's login manager here is Plasma Login Manager (package
# `plasma-login-manager`, service `plasmalogin`), not classic SDDM — per
# https://wiki.archlinux.org/title/Activating_numlock_on_bootup#Plasma_Login_Manager
# its NumLock setting lives in a config file under the `plasmalogin` system
# user's home, not /etc/sddm.conf.d (that path is Hyprland's, see
# arch/components/sddm-numlock.sh).
#
# Package lists live under arch/packages/kde-*.txt, not inline here.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_kde_component() {
    log_section "KDE Plasma Desktop"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/arch/packages/kde-base.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/arch/packages/kde-media.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/arch/packages/kde-thumbnails.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    if systemctl is-enabled --quiet sddm.service 2>/dev/null; then
        log_info "Disabling sddm.service (KDE here uses plasma-login-manager instead)..."
        sudo systemctl disable sddm.service
    fi
    if systemctl is-enabled --quiet plasmalogin.service 2>/dev/null; then
        log_success "plasmalogin.service already enabled"
    else
        sudo systemctl enable plasmalogin.service
        log_success "plasmalogin.service enabled"
    fi
    _configure_plasma_login_manager_numlock
    _configure_kde_session_numlock

    log_success "KDE Plasma desktop setup complete"
}

_configure_plasma_login_manager_numlock() {
    log_info "Configuring Plasma Login Manager NumLock..."
    local dir="/var/lib/plasmalogin/.config/kdedefaults"
    sudo mkdir -p "$dir"
    sudo tee "$dir/kcminputrc" > /dev/null <<'EOF'
[Keyboard]
NumLock=0
EOF
    sudo chown -R plasmalogin:plasmalogin /var/lib/plasmalogin/.config
    log_success "Plasma Login Manager NumLock enabled"
}

_kwriteconfig() {
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 "$@"
    elif command -v kwriteconfig5 >/dev/null 2>&1; then
        kwriteconfig5 "$@"
    else
        return 1
    fi
}

_configure_kde_session_numlock() {
    log_info "Configuring Plasma session NumLock..."
    # kcminputrc's Keyboard/NumLock: 0 = on, 1 = off, 2 = leave unchanged.
    if _kwriteconfig --file kcminputrc --group Keyboard --key NumLock 0; then
        log_success "Plasma session NumLock set to on (~/.config/kcminputrc)"
    else
        log_warn "kwriteconfig6/kwriteconfig5 not found — skipping session NumLock" \
            "(it ships with plasma-desktop, so this shouldn't happen; set it" \
            "manually via System Settings > Input Devices > Keyboard if needed)"
    fi
}
