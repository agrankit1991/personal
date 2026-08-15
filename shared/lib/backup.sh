#!/bin/bash
# Idempotent "put a config file/dir into place" helpers, in two flavours.
#
# link_file/link_dir symlink the destination at the tracked copy in this repo,
# so editing a config here takes effect immediately with no re-run of the
# installer. This is the default for anything only ever edited by hand. The
# links hold an absolute path, so the repo is expected to stay where it was
# first cloned.
#
# install_file/install_dir copy instead. Reserved for configs the application
# itself rewrites (COSMIC's, which churn as you use the desktop) — linking
# those would leave the repo permanently dirty and make capture-config.sh,
# which pulls UI changes back in, meaningless.
#
# All four are safe to run repeatedly:
#   - a no-op (not even a backup) if the destination already matches
#   - the FIRST run against a pre-existing, differing destination backs it up
#     once to DEST.backup; later re-runs never overwrite that backup with
#     something we installed ourselves, so the true original is preserved.
#
# Source this file; do not execute it directly. Depends on shared/lib/log.sh.

# Clears a destination so a fresh copy or link can take its place, preserving
# whatever was there before us exactly once. Three things are recognisably
# ours rather than the user's, and are discarded rather than backed up:
#   - a symlink, since only these helpers ever create one at a destination
#   - a destination whose content already matches the source byte for byte
#     (this is what keeps the copies-to-links conversion from manufacturing a
#     .backup of our own previously-installed copy at every destination)
#   - anything at all once a DEST.backup already exists, which by definition
#     holds the true original
_clear_dest() {
    local dest="$1" src="$2"
    if [ -L "$dest" ]; then
        rm -f "$dest"
    elif [ -e "$dest" ]; then
        if [ -e "${dest}.backup" ] || _same_content "$src" "$dest"; then
            rm -rf "$dest"
        else
            mv "$dest" "${dest}.backup"
            log_warn "Backed up existing $(basename "$dest") to $(basename "$dest").backup"
        fi
    fi
    return 0
}

_same_content() {
    local src="$1" dest="$2"
    if [ -d "$src" ]; then
        diff -rq "$src" "$dest" >/dev/null 2>&1
    else
        cmp -s "$src" "$dest"
    fi
}

link_file() {
    local src="$1" dest="$2"
    if [ "$(readlink "$dest" || true)" = "$src" ]; then
        log_success "$(basename "$dest") already linked"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    _clear_dest "$dest" "$src"
    ln -s "$src" "$dest"
    log_success "Linked $(basename "$dest")"
}

# Identical to link_file bar the logging — the destination becomes a link to
# the source directory itself, not a directory of per-file links, so a file
# added to the repo shows up without re-running the installer.
link_dir() {
    local src="$1" dest="$2"
    if [ "$(readlink "$dest" || true)" = "$src" ]; then
        log_success "$(basename "$dest")/ already linked"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    _clear_dest "$dest" "$src"
    ln -s "$src" "$dest"
    log_success "Linked $(basename "$dest")/"
}

# The `! -L` in the up-to-date checks matters: a symlink to the source
# compares equal to it, so without that guard a destination left behind by an
# earlier link_* run would be reported up to date and never become a real copy.
install_file() {
    local src="$1" dest="$2"
    if [ ! -L "$dest" ] && [ -e "$dest" ] && cmp -s "$src" "$dest"; then
        log_success "$(basename "$dest") already up to date"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    _clear_dest "$dest" "$src"
    cp "$src" "$dest"
    log_success "Installed $(basename "$dest")"
}

install_dir() {
    local src="$1" dest="$2"
    if [ ! -L "$dest" ] && [ -d "$dest" ] && diff -rq "$src" "$dest" >/dev/null 2>&1; then
        log_success "$(basename "$dest")/ already up to date"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    _clear_dest "$dest" "$src"
    cp -r "$src" "$dest"
    log_success "Installed $(basename "$dest")/"
}
