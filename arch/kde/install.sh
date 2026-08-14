#!/bin/bash
# KDE Plasma desktop install — single TUI entrypoint.
#
# Usage:
#   ./arch/kde/install.sh
#
# Only "KDE Plasma desktop setup" and "Disk utility" are pre-selected —
# everything else is opt-in.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/shared/lib/log.sh"
source "$REPO_ROOT/shared/lib/sudo.sh"
source "$REPO_ROOT/shared/lib/backup.sh"
source "$REPO_ROOT/shared/lib/prompt.sh"
source "$REPO_ROOT/shared/lib/packages.sh"
source "$REPO_ROOT/arch/lib/pacman.sh"
source "$REPO_ROOT/shared/install-dotfiles.sh"
source "$REPO_ROOT/shared/install-oh-my-zsh.sh"
source "$REPO_ROOT/shared/install-mise.sh"
source "$REPO_ROOT/shared/install-starship.sh"
source "$REPO_ROOT/shared/install-lazyvim.sh"
source "$REPO_ROOT/shared/install-git.sh"
source "$REPO_ROOT/arch/components/terminal.sh"
source "$REPO_ROOT/arch/components/dev-tools.sh"
source "$REPO_ROOT/arch/components/postgres.sh"
source "$REPO_ROOT/arch/components/apps.sh"
source "$REPO_ROOT/arch/components/disk-utility.sh"
source "$REPO_ROOT/arch/components/power-profiles.sh"
source "$SCRIPT_DIR/setup.sh"

require_not_root
log_section "KDE Plasma Desktop Install"

checkbox_menu "Select components to install" \
    "terminal|Terminal environment (zsh, starship, CLI tools, neovim)|off" \
    "dev-tools|Dev tools (Docker, mise: Java/Node/Gradle)|off" \
    "postgres|PostgreSQL (local dev database)|off" \
    "apps|GUI apps (VS Code, Brave, OpenCode, Obsidian, ...)|off" \
    "git|Git/SSH configuration|off" \
    "disk-utility|Disk utility (GNOME Disks + FAT32/NTFS support)|on" \
    "power-profiles|Power profiles (power-profiles-daemon)|on" \
    "kde|KDE Plasma desktop setup|on"

if [ "${#MENU_RESULT[@]}" -eq 0 ]; then
    log_warn "Nothing selected — exiting."
    exit 0
fi

cache_sudo
sync_pacman
ensure_paru

menu_has terminal       && install_terminal_component
menu_has dev-tools      && install_dev_tools_component
menu_has postgres       && install_postgres_component
menu_has apps           && install_apps_component
menu_has git            && install_git
menu_has disk-utility   && install_disk_utility_component
menu_has power-profiles && install_power_profiles_component
menu_has kde            && install_kde_component

log_section "Done"
log_success "Selected components installed"
log_info "Reboot to start Plasma via Plasma Login Manager."
