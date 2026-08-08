#!/bin/bash
# Optional "PostgreSQL" component for macOS: Homebrew's postgresql service
# plus a throwaway dev role/database, matching arch/components/postgres.sh.
#
# Depends on: shared/lib/{log,packages}.sh, macos/lib/brew.sh.

install_postgres_component() {
    log_section "PostgreSQL"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/macos/packages/postgres.txt"
    install_pkg "${PACKAGE_LIST[@]}"
    brew services start postgresql >/dev/null

    # Homebrew's postgresql runs under the invoking user, so no `sudo -u
    # postgres` dance is needed here the way there is on Linux.
    if psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='dev'" postgres 2>/dev/null | grep -q 1; then
        log_success "'dev' role already exists"
    else
        psql -v ON_ERROR_STOP=1 postgres <<'EOF'
CREATE USER dev WITH PASSWORD 'dev' CREATEDB;
CREATE DATABASE dev OWNER dev;
EOF
        log_success "Created 'dev' role and database"
    fi

    log_success "PostgreSQL ready"
    log_info "Connect with: psql postgresql://dev:dev@localhost:5432/dev"
}
