# ===============================
# Custom Functions
# ===============================

# Create directory and cd into it
function mcd() {
    mkdir -p "$@" && cd "$_"
}

# Quick find function using 'fd' (modern find replacement)
# Install: sudo pacman -S fd
function f() {
    fd "$1"
}

# Extract various archive formats
function extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar e "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup function
function backup() {
    local filename="$1.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r "$1" "$filename"
    echo "Backup created: $filename"
}

# Quick project navigation
function proj() {
    if [[ -z "$1" ]]; then
        cd ~/Developer && ls
    else
        cd ~/Developer/"$1" && ls
    fi
}

# Git clone and cd
function gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Create and switch to a new git branch
function gcb() {
    git checkout -b "$1"
}

# Show directory tree (using eza for better visuals)
# Install: sudo pacman -S eza
function tree-git() {
    eza --tree --icons --ignore-glob=".git|node_modules|__pycache__"
}

# Weather function
function weather() {
    local city="${1:-}"
    curl -s "wttr.in/${city}?format=3"
}

# Quick note-taking
function note() {
    local note_file="$HOME/notes.txt"
    if [[ $# -eq 0 ]]; then
        cat "$note_file" 2>/dev/null || echo "No notes found"
    else
        echo "$(date): $*" >> "$note_file"
        echo "Note added: $*"
    fi
}

# ===============================
# Arch Linux System Functions
# ===============================

function update-system() {
    echo "--- Updating Arch Linux (Official & AUR) ---"
    # Update official and AUR packages via paru
    paru -Syu

    # Update Flatpaks if you use them
    if command -v flatpak &> /dev/null; then
        echo "--- Updating Flatpaks ---"
        flatpak update -y
    fi
    echo "System updated successfully!"
}

function clean-system() {
    echo "--- Cleaning Arch Linux ---"

    # Remove orphan packages
    local orphans=$(pacman -Qtdq)
    if [[ -n "$orphans" ]]; then
        echo "Removing orphans..."
        sudo pacman -Rns $orphans
    else
        echo "No orphans to clean."
    fi

    # Clean pacman cache (keeps latest 2 versions of installed packages)
    # Requires 'pacman-contrib' package for 'paccache'
    if command -v paccache &> /dev/null; then
        echo "Cleaning package cache..."
        sudo paccache -rk2
    else
        echo "Cleaning all cached packages..."
        sudo pacman -Scc --noconfirm
    fi

    # Clean Flatpaks
    if command -v flatpak &> /dev/null; then
        flatpak uninstall --unused -y
    fi

    echo "System cleaned successfully!"
}
