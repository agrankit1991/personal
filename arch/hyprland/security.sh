#!/bin/bash
# Optional "security hardening" component for Hyprland: a default-deny
# firewall (ufw) and AppArmor enforcement. Deliberately does NOT edit
# /etc/default/grub — adding the `lsm=` kernel parameter AppArmor needs to
# actually enforce (rather than just run) touches the bootloader, so that
# step is printed for the user to apply by hand instead of being sed'd in.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_hyprland_security_component() {
    log_section "Security Hardening"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/arch/packages/security-ufw.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw --force enable
    log_success "ufw enabled (default deny incoming / allow outgoing)"

    read_package_list "$repo_root/arch/packages/security-apparmor.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    sudo systemctl enable --now apparmor.service
    log_success "AppArmor service enabled"

    log_warn "Manual step (edits the bootloader, not automated): AppArmor" \
        "only *runs* until you add 'apparmor=1 security=apparmor' to" \
        "GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub and run" \
        "'sudo grub-mkconfig -o /boot/grub/grub.cfg', then reboot."
}
