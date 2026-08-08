#!/bin/bash
# Idempotent "install a config file/dir into place" helpers.
#
# Both are safe to run repeatedly:
#   - a no-op (not even a backup) if the destination already matches
#   - the FIRST run against a pre-existing, differing file backs it up once
#     to DEST.backup; later re-runs never overwrite that backup with our own
#     previously-installed copy, so the user's true original is preserved.
#
# Source this file; do not execute it directly. Depends on shared/lib/log.sh.

install_file() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] && cmp -s "$src" "$dest"; then
        log_success "$(basename "$dest") already up to date"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -e "${dest}.backup" ]; then
        cp -r "$dest" "${dest}.backup"
        log_warn "Backed up existing $(basename "$dest") to $(basename "$dest").backup"
    fi
    cp "$src" "$dest"
    log_success "Installed $(basename "$dest")"
}

install_dir() {
    local src="$1" dest="$2"
    if [ -d "$dest" ] && diff -rq "$src" "$dest" >/dev/null 2>&1; then
        log_success "$(basename "$dest")/ already up to date"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -e "${dest}.backup" ]; then
        mv "$dest" "${dest}.backup"
        log_warn "Backed up existing $(basename "$dest")/ to $(basename "$dest").backup"
    fi
    cp -r "$src" "$dest"
    log_success "Installed $(basename "$dest")/"
}
