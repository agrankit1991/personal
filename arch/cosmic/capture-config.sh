#!/bin/bash
# Copies the live COSMIC settings listed in config/cosmic-ids.txt out of
# ~/.config/cosmic and into this repo.
#
# setup.sh installs those directories wholesale, which means anything you
# change afterwards in COSMIC Settings is overwritten on the next run. This
# is the other half of that loop: tweak the theme, panel or dock in the UI,
# run this, review the diff, commit.
#
# Usage:
#   ./arch/cosmic/capture-config.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_ROOT/shared/lib/log.sh"
source "$REPO_ROOT/shared/lib/packages.sh"

require_not_root
log_section "Capture COSMIC Config"

read_package_list "$SCRIPT_DIR/config/cosmic-ids.txt"

captured=0
for cfg_id in "${PACKAGE_LIST[@]}"; do
    src="$HOME/.config/cosmic/$cfg_id"
    dst="$SCRIPT_DIR/config/cosmic/$cfg_id"

    if [ ! -d "$src" ]; then
        log_warn "$cfg_id not present in ~/.config/cosmic — skipped"
        continue
    fi

    # Replace rather than merge, so a setting removed in the UI also
    # disappears here instead of lingering as a stale tracked file.
    rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"

    # install_file drops a DEST.backup next to anything it replaced. Those
    # are local artefacts of a previous install, not settings, and tracking
    # one would install it right back on the next run.
    find "$dst" -name '*.backup' -delete

    log_success "$cfg_id ($(find "$dst" -type f | wc -l) files)"
    captured=$((captured + 1))
done

log_success "Captured $captured config directories"
log_info "Review with 'git diff' and commit if it looks right."
