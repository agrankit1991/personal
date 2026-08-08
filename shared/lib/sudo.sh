#!/bin/bash
# sudo credential caching, kept separate from log.sh (single responsibility).
# Source this file; do not execute it directly.

# Prompts for the sudo password once, up front, and refreshes it in the
# background for the lifetime of the script. Without this, a sudo prompt
# that fires later while a TUI (gum) has control of the terminal can appear
# to hang the script.
cache_sudo() {
    sudo -v
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
    _SUDO_KEEPALIVE_PID=$!
    trap '[ -n "${_SUDO_KEEPALIVE_PID:-}" ] && kill "$_SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
}
