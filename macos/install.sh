#!/bin/bash
# macOS setup — single TUI entrypoint.
#
# Usage:
#   ./macos/install.sh
#
# Unlike the Arch scripts, there's no single "desktop setup" here — macOS's
# desktop is the OS — so nothing is forced on. Pick what you want.
#
# Note: macOS ships bash 3.2 at /bin/bash. This script and everything it
# sources deliberately avoid bash 4+-only features (associative arrays,
# `declare -n`) so it runs correctly under that stock bash.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$REPO_ROOT/shared/lib/log.sh"
source "$REPO_ROOT/shared/lib/sudo.sh"
source "$REPO_ROOT/shared/lib/backup.sh"
source "$REPO_ROOT/shared/lib/prompt.sh"
source "$REPO_ROOT/shared/lib/packages.sh"
source "$REPO_ROOT/macos/lib/brew.sh"
source "$REPO_ROOT/shared/install-dotfiles.sh"
source "$REPO_ROOT/shared/install-oh-my-zsh.sh"
source "$REPO_ROOT/shared/install-mise.sh"
source "$REPO_ROOT/shared/install-starship.sh"
source "$REPO_ROOT/shared/install-lazyvim.sh"
source "$REPO_ROOT/shared/install-git.sh"
source "$SCRIPT_DIR/components/terminal.sh"
source "$SCRIPT_DIR/components/dev-tools.sh"
source "$SCRIPT_DIR/components/postgres.sh"
source "$SCRIPT_DIR/components/apps.sh"

require_not_root
log_section "macOS Setup"

checkbox_menu "Select components to install" \
    "terminal|Terminal environment (zsh, starship, CLI tools, neovim)|on" \
    "dev-tools|Dev tools (Docker, mise: Java/Node/Gradle)|off" \
    "postgres|PostgreSQL (local dev database)|off" \
    "apps|GUI apps (VS Code, Brave, Obsidian, ...)|off" \
    "git|Git/SSH configuration|off"

if [ "${#MENU_RESULT[@]}" -eq 0 ]; then
    log_warn "Nothing selected — exiting."
    exit 0
fi

cache_sudo
ensure_xcode_command_line_tools
ensure_homebrew

menu_has terminal      && install_terminal_component
menu_has dev-tools     && install_dev_tools_component
menu_has postgres      && install_postgres_component
menu_has apps          && install_apps_component
menu_has git           && install_git osxkeychain

log_section "Done"
log_success "Selected components installed"
