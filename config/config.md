# Install Java
mise use --global java@temurin-21 java@temurin-17 java@temurin-8

# Install build tools
mise use --global gradle@latest maven@latest

# Install nodejs (npm)
mise use --global node@lts

# Install PostgresSQL
sudo pacman -S bison flex base-devel
mise use --global postgres@17

mkdir -p ~/.local/share/postgres
initdb -D ~/.local/share/postgres
pg_ctl -D ~/.local/share/postgres -l logfile start

alias pgstart="pg_ctl -D ~/.local/share/postgres -l logfile start"
alias pgstop="pg_ctl -D ~/.local/share/postgres stop"
alias pgstatus="pg_ctl -D ~/.local/share/postgres status"

-------------------------

# Prevent SSH timeout
sudo vi ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
