# ===============================
# Custom Functions (Bash)
# ===============================

# Create directory and cd into it
# Note: In Bash, $_ is not reliable inside functions like it is in Zsh.
# We must reuse the argument variable ($1).
function mcd() {
    mkdir -p "$1" && \cd "$1"
}

# Quick find function
function f() {
    find . -name "*$1*"
}

# Extract various archive formats
function extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"      ;;
            *.tar.gz)    tar xzf "$1"      ;;
            *.bz2)       bunzip2 "$1"      ;;
            *.rar)       unrar e "$1"      ;;
            *.gz)        gunzip "$1"       ;;
            *.tar)       tar xf "$1"       ;;
            *.tbz2)      tar xjf "$1"      ;;
            *.tgz)       tar xzf "$1"      ;;
            *.zip)       unzip "$1"        ;;
            *.Z)         uncompress "$1"   ;;
            *.7z)        7z x "$1"         ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup function
function backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: $1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Quick project navigation (Updated path to match 'wp' alias if needed)
function proj() {
    local proj_dir="$HOME/code"  # Changed from ~/Developer to ~/code to match standard
    if [[ -z "$1" ]]; then
        cd "$proj_dir" && ls
    else
        cd "$proj_dir/$1" && ls
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

# Show directory tree with git status
function tree-git() {
    tree -I '.git|node_modules|__pycache__|*.pyc'
}

# Weather function (requires curl)
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
