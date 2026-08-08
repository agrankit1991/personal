#!/bin/bash
# Hyprland desktop-specific setup: compositor + Wayland utilities, SDDM,
# fonts, the Hyprland config tree, uwsm, gnome-keyring, and the GNOME app
# suite Hyprland doesn't bundle on its own (file manager, media players,
# thumbnailers).
#
# Package lists live under arch/packages/hyprland-*.txt, not inline here.
#
# Depends on: shared/lib/{log,backup,packages}.sh, arch/lib/pacman.sh,
# arch/components/sddm-numlock.sh.

install_hyprland_component() {
    log_section "Hyprland Desktop"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    read_package_list "$repo_root/arch/packages/hyprland-base.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/arch/packages/hyprland-fonts.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/arch/packages/hyprland-aur.txt"
    install_aur "${PACKAGE_LIST[@]}"

    xdg-user-dirs-update

    if systemctl is-enabled --quiet sddm.service 2>/dev/null; then
        log_success "sddm.service already enabled"
    else
        sudo systemctl enable sddm.service
        log_success "sddm.service enabled"
    fi
    configure_sddm_numlock

    _install_hypr_config
    _install_hypr_keyring
    _install_hypr_uwsm
    _install_hypr_gnome_apps
    _install_hypr_wallpaper_cron

    log_success "Hyprland desktop setup complete"
    log_warn "Manual step (boot-critical, not automated): to also apply NumLock" \
        "before disk decryption, add 'numlock' to HOOKS in /etc/mkinitcpio.conf" \
        "(before 'encrypt' if you use one), then run 'sudo mkinitcpio -P'." \
        "See: https://wiki.archlinux.org/title/Activating_numlock_on_bootup"
}

_install_hypr_config() {
    local src_dir
    src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"

    log_info "Installing Hyprland config..."
    install_dir "$src_dir/hypr" "$HOME/.config/hypr"
    install_dir "$src_dir/waybar" "$HOME/.config/waybar"
    install_dir "$src_dir/rofi" "$HOME/.config/rofi"
    install_dir "$src_dir/swaync" "$HOME/.config/swaync"
    install_file "$src_dir/brave-flags.conf" "$HOME/.config/brave-flags.conf"
    install_file "$src_dir/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    install_dir "$repo_root/arch/hyprland/scripts" "$HOME/scripts"
    install_dir "$repo_root/arch/hyprland/themes/icons" "$HOME/.local/share/icons"
    install_dir "$repo_root/arch/hyprland/wallpapers" "$HOME/Pictures/Wallpapers"
}

_install_hypr_keyring() {
    log_info "Installing gnome-keyring (secrets service + SSH agent)..."
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/hyprland-keyring.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    systemctl --user enable --now gnome-keyring-daemon.service gnome-keyring-daemon.socket gcr-ssh-agent.socket
    log_success "gnome-keyring services enabled"
    log_warn "Manual step (edits /etc/pam.d/login, not automated): to unlock the" \
        "keyring automatically at login, add 'pam_gnome_keyring.so' to the auth" \
        "and session sections of /etc/pam.d/login. See hyprland setup notes in" \
        "the README for the exact lines."
}

_install_hypr_uwsm() {
    log_info "Installing uwsm..."
    install_pkg uwsm
    local src_dir
    src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config/uwsm"
    install_file "$src_dir/hyprland.desktop" "$HOME/.config/uwsm/hyprland.desktop"
    install_file "$src_dir/env" "$HOME/.config/uwsm/env"
}

_install_hypr_gnome_apps() {
    log_info "Installing GNOME app suite (file manager, media, previews)..."
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/hyprland-gnome-apps.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    read_package_list "$repo_root/arch/packages/hyprland-codecs.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    log_info "Setting default apps (xdg-mime)..."
    xdg-mime default org.gnome.Nautilus.desktop inode/directory
    xdg-mime default org.gnome.Loupe.desktop image/png image/jpeg image/gif image/webp image/svg+xml
    xdg-mime default org.gnome.Showtime.desktop video/mp4 video/mkv video/webm video/x-matroska
    xdg-mime default org.gnome.Amberol.desktop audio/mpeg audio/flac audio/ogg
    xdg-mime default org.gnome.Papers.desktop application/pdf
    xdg-mime default org.gnome.font-viewer.desktop application/x-font-ttf application/x-font-otf application/font-sfnt font/ttf font/otf
    xdg-mime default org.gnome.Calendar.desktop text/calendar
    xdg-mime default code.desktop text/plain text/markdown text/x-markdown text/x-java-source text/x-java
    xdg-mime default code.desktop text/x-c text/x-c++ text/x-python text/x-javascript application/json application/xml
    xdg-mime default code.desktop text/x-script text/x-shellscript
    log_success "GNOME app suite ready"
}

_install_hypr_wallpaper_cron() {
    log_info "Setting up wallpaper shuffler cron job..."
    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/hyprland-cron.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    if systemctl is-enabled --quiet cronie.service 2>/dev/null; then
        log_success "cronie.service already enabled"
    else
        sudo systemctl enable --now cronie.service
        log_success "cronie.service enabled"
    fi

    local marker="# hyprland-wallpaper-shuffler (personal-script)"
    local cron_line="*/30 * * * * \$HOME/scripts/helper-wallpaper-shuffler $marker"
    if crontab -l 2>/dev/null | grep -qF "$marker"; then
        log_success "Wallpaper shuffler cron entry already present"
    else
        { crontab -l 2>/dev/null; echo "$cron_line"; } | crontab -
        log_success "Wallpaper shuffler cron entry added (every 30 min)"
    fi
}
