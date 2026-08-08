#!/bin/bash
# Optional "PostgreSQL" component: a local system-service Postgres instance
# for development, with a throwaway dev role/database.
#
# Depends on: shared/lib/{log,packages}.sh, arch/lib/pacman.sh.

install_postgres_component() {
    log_section "PostgreSQL"

    local repo_root
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    read_package_list "$repo_root/arch/packages/postgres.txt"
    install_pkg "${PACKAGE_LIST[@]}"

    if [ -d /var/lib/postgres/data ] && [ -n "$(ls -A /var/lib/postgres/data 2>/dev/null)" ]; then
        log_success "PostgreSQL data directory already initialized"
    else
        log_info "Initializing PostgreSQL data directory..."
        sudo -u postgres initdb -D /var/lib/postgres/data
        log_success "PostgreSQL initialized"
    fi

    sudo systemctl enable --now postgresql

    if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='dev'" | grep -q 1; then
        log_success "'dev' role already exists"
    else
        sudo -u postgres psql -v ON_ERROR_STOP=1 <<'EOF'
CREATE USER dev WITH PASSWORD 'dev' CREATEDB;
CREATE DATABASE dev OWNER dev;
EOF
        log_success "Created 'dev' role and database"
    fi

    log_success "PostgreSQL ready"
    log_info "Connect with: psql postgresql://dev:dev@localhost:5432/dev"
}
