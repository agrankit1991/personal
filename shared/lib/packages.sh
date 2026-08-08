#!/bin/bash
# Reads a package-list file into the global array PACKAGE_LIST (a plain
# global, not a nameref, for bash 3.2 compatibility — same convention as
# MENU_RESULT in prompt.sh).
#
# Package/app lists live as plain text under */packages/ — one name per
# line, blank lines and full-line '#' comments ignored — specifically so
# they're easy to review and edit without reading bash. Names that are
# identical across pacman and Homebrew live in shared/packages/; anything
# OS- or component-specific lives under arch/packages/ or macos/packages/.
#
# Source this file; do not execute it directly.

read_package_list() {
    local file="$1"
    PACKAGE_LIST=()
    local line
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ''|'#'*) continue ;;
        esac
        PACKAGE_LIST+=("$line")
    done < "$file"
}
