#!/bin/bash
# Power profiles component, shared by every Arch desktop script:
# power-profiles-daemon, the D-Bus service the COSMIC/KDE power widgets (and
# waybar's power-profiles-daemon module under Hyprland) talk to for
# Performance / Balanced / Power Saver switching.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_power_profiles_component() {
    log_section "Power Profiles"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/power-profiles.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    # tlp claims the same power-management knobs; running both leaves the
    # daemon dead and the desktop's profile switcher greyed out. Warn rather
    # than disable it — which of the two you want is a real choice.
    if systemctl is-enabled --quiet tlp.service 2>/dev/null; then
        log_warn "tlp is enabled and conflicts with power-profiles-daemon"
        log_warn "Disable one of them: 'sudo systemctl disable --now tlp.service'"
    fi

    if systemctl is-active --quiet power-profiles-daemon; then
        log_success "power-profiles-daemon service already running"
    else
        log_info "Enabling and starting power-profiles-daemon service..."
        sudo systemctl enable --now power-profiles-daemon.service
        log_success "power-profiles-daemon service enabled and started"
    fi

    log_success "Power profiles ready"
    log_info "Switch from the CLI with: powerprofilesctl set balanced"
}
