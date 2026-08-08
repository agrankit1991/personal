#!/bin/bash
# COSMIC desktop-specific setup: GTK portal (so GTK apps behave under
# COSMIC) and the cosmic-greeter NumLock config. COSMIC bundles its own
# file manager/media apps, so there's no GNOME-app-suite step here the way
# there is for Hyprland.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_cosmic_component() {
    log_section "COSMIC Desktop"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/cosmic.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    log_info "Configuring COSMIC greeter NumLock..."
    local greeter_dir="/var/lib/cosmic-greeter/.config/cosmic/com.system76.CosmicComp/v1"
    sudo mkdir -p "$greeter_dir"
    sudo tee "$greeter_dir/keyboard_config" > /dev/null <<'EOF'
(
numlock_state: BootOn,
)
EOF
    log_success "COSMIC greeter NumLock enabled"
    log_success "COSMIC desktop setup complete"
}
