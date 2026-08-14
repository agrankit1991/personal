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

    # COSMIC has a built-in network applet, so network-manager-applet only
    # adds a duplicate tray icon. Nothing here installs it — it arrives as a
    # dependency of other desktop stacks — so remove it explicitly.
    log_info "Removing duplicate network tray applet..."
    remove_pkg network-manager-applet

    # Universal copy/paste: SUPER+C and SUPER+V everywhere, the way Omarchy
    # does it on Hyprland. COSMIC's shortcut actions can only spawn commands
    # or drive windows — there's no "send a keystroke" action — so the remap
    # has to happen below the compositor, in keyd.
    #
    # Ctrl+Insert / Shift+Insert are the targets because they're the legacy
    # copy/paste combos that GTK, Qt, Electron and terminals all honour, so
    # one binding covers every app without per-window special-casing.
    #
    # `[meta:M]` is load-bearing: explicit bindings in a modifier layer drop
    # the layer's own modifier (giving a clean Ctrl+Insert), while unmapped
    # keys keep Meta — which is what leaves SUPER+W, SUPER+E and the rest of
    # the COSMIC shortcuts working.
    log_info "Configuring universal copy/paste (keyd)..."
    sudo mkdir -p /etc/keyd
    sudo tee /etc/keyd/default.conf > /dev/null <<'EOF'
[ids]
*

[meta:M]
c = C-insert
v = S-insert
EOF
    sudo systemctl enable --now keyd.service
    sudo keyd reload
    log_success "SUPER+C / SUPER+V bound to copy/paste"

    log_success "COSMIC desktop setup complete"
}
