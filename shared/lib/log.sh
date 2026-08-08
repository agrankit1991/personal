#!/bin/bash
# Logging helpers shared by every install script in this repo.
# Source this file; do not execute it directly.

readonly _LOG_RED=$'\033[0;31m'
readonly _LOG_GREEN=$'\033[0;32m'
readonly _LOG_YELLOW=$'\033[0;33m'
readonly _LOG_BLUE=$'\033[0;34m'
readonly _LOG_RESET=$'\033[0m'

log_section() {
    printf '\n%s========================================%s\n' "$_LOG_BLUE" "$_LOG_RESET"
    printf '%s%s%s\n' "$_LOG_BLUE" "$1" "$_LOG_RESET"
    printf '%s========================================%s\n\n' "$_LOG_BLUE" "$_LOG_RESET"
}

# Each of these joins all its arguments with a space (so a message can be
# split across multiple quoted strings for readability at the call site).
log_info()    { printf '%s\n' "$*"; }
log_success() { printf '%s✓ %s%s\n' "$_LOG_GREEN" "$*" "$_LOG_RESET"; }
log_warn()    { printf '%s⚠ %s%s\n' "$_LOG_YELLOW" "$*" "$_LOG_RESET"; }
log_error()   { printf '%s✗ %s%s\n' "$_LOG_RED" "$*" "$_LOG_RESET" >&2; }

# Aborts the script. Use for unrecoverable setup errors.
die() {
    log_error "$1"
    exit 1
}

require_not_root() {
    if [ "$EUID" -eq 0 ]; then
        die "Please do not run this script as root (it uses sudo where needed)."
    fi
}
