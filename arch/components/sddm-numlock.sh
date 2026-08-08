#!/bin/bash
# SDDM login-screen NumLock, used by the Hyprland desktop script (COSMIC
# uses cosmic-greeter — see arch/cosmic/setup.sh — and KDE here uses Plasma
# Login Manager instead of SDDM — see arch/kde/setup.sh). Writes a dedicated
# drop-in so it never clobbers other SDDM settings, and is naturally
# idempotent (same content every run).
#
# Depends on: shared/lib/log.sh.

configure_sddm_numlock() {
    log_info "Configuring SDDM NumLock..."
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/numlock.conf > /dev/null <<'EOF'
[General]
Numlock=on
EOF
    log_success "SDDM NumLock enabled (/etc/sddm.conf.d/numlock.conf)"
}
