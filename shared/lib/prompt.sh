#!/bin/bash
# TUI helpers: a checkbox component menu backed by `gum`, with a plain-bash
# fallback when gum isn't installed. Deliberately avoids bash 4+ only
# features (associative arrays, `declare -n` namerefs) so the same code runs
# under both Arch's bash and macOS's stock bash 3.2.
#
# Source this file; do not execute it directly. Depends on shared/lib/log.sh.

# Yes/no confirmation. Returns 0 for yes, 1 for no.
confirm() {
    local prompt="$1" default="${2:-y}"
    if command -v gum >/dev/null 2>&1; then
        local flag=""
        [ "$default" = "y" ] && flag="--default=true" || flag="--default=false"
        gum confirm "$prompt" "$flag"
        return $?
    fi
    local suffix="y/N" ans
    [ "$default" = "y" ] && suffix="Y/n"
    read -r -p "$prompt [$suffix] " ans
    ans="${ans:-$default}"
    case "$ans" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

# checkbox_menu TITLE ITEM...
# Each ITEM is "key|Label shown to the user|on" or "...|off" for the default
# selection state. Leaves the selected keys in the global array MENU_RESULT
# (a plain global, not a nameref, for bash 3.2 compatibility).
#
# IMPORTANT: call this as a bare statement (as every install.sh does), never
# as part of a pipeline / command substitution / `(...)` subshell. Bash runs
# the right-hand side of a pipe in a subshell, so `MENU_RESULT` would be set
# there and silently vanish when the subshell exits, leaving the caller with
# an empty array and no error.
checkbox_menu() {
    local title="$1"
    shift
    local items=("$@")
    MENU_RESULT=()

    local keys=() labels=() defaults=()
    local item rest
    for item in "${items[@]}"; do
        keys+=("${item%%|*}")
        rest="${item#*|}"
        labels+=("${rest%%|*}")
        defaults+=("${rest##*|}")
    done

    if command -v gum >/dev/null 2>&1; then
        local preselected="" i chosen line
        for i in "${!labels[@]}"; do
            [ "${defaults[$i]}" = "on" ] && preselected+="${labels[$i]},"
        done
        # `|| true`: under `set -e`, a failing command substitution (e.g. the
        # user hits Esc/Ctrl+C with nothing chosen) would otherwise abort the
        # whole script here instead of just yielding an empty selection.
        chosen=$(gum choose --no-limit --header="$title" --selected="${preselected%,}" "${labels[@]}") || true
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            for i in "${!labels[@]}"; do
                [ "${labels[$i]}" = "$line" ] && MENU_RESULT+=("${keys[$i]}")
            done
        done <<< "$chosen"
        return 0
    fi

    log_warn "gum not found — falling back to per-item y/n prompts for: $title"
    log_info "(install 'gum' for a proper checkbox menu: https://github.com/charmbracelet/gum)"
    local i suffix ans
    for i in "${!labels[@]}"; do
        suffix="y/N"
        [ "${defaults[$i]}" = "on" ] && suffix="Y/n"
        read -r -p "  Install ${labels[$i]}? [$suffix] " ans
        ans="${ans:-${defaults[$i]}}"
        case "$ans" in
            [Yy]*|on) MENU_RESULT+=("${keys[$i]}") ;;
        esac
    done
}

# menu_has KEY — true if KEY was selected in the last checkbox_menu call.
menu_has() {
    local k
    for k in "${MENU_RESULT[@]}"; do
        [ "$k" = "$1" ] && return 0
    done
    return 1
}
