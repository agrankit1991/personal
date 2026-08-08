#!/bin/bash
# Git identity, aliases, global excludes/commit template, and SSH keypair.
# OS-agnostic except for an optional credential helper.
#
# Usage:
#   install_git                  # Linux: no credential.helper forced
#   install_git osxkeychain      # macOS
#
# Idempotent: re-running never re-prompts for an SSH key overwrite and never
# spawns a duplicate ssh-agent.
# Depends on shared/lib/log.sh and shared/lib/backup.sh.

_GIT_USER_NAME="Ankit Agrawal"
_GIT_USER_EMAIL="hiankit@zohomail.in"

install_git() {
    local credential_helper="${1:-}"
    local shared_git_dir
    shared_git_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config/git"

    log_info "Configuring git..."
    git config --global user.name "$_GIT_USER_NAME"
    git config --global user.email "$_GIT_USER_EMAIL"
    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    git config --global core.autocrlf input
    git config --global color.ui true
    git config --global pull.rebase true

    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
    git config --global alias.lp "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"

    install_file "$shared_git_dir/gitignore" "$HOME/.config/git/.gitignore"
    install_file "$shared_git_dir/gitmessage" "$HOME/.config/git/.gitmessage"
    git config --global core.excludesfile "$HOME/.config/git/.gitignore"
    git config --global commit.template "$HOME/.config/git/.gitmessage"

    if [ -n "$credential_helper" ]; then
        git config --global credential.helper "$credential_helper"
    fi
    log_success "Git configuration complete"

    _install_ssh_key
}

_install_ssh_key() {
    log_info "Setting up SSH key for GitHub..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        log_success "SSH key already exists at ~/.ssh/id_ed25519 — skipping generation"
    else
        # -f avoids ssh-keygen's interactive "enter file in which to save
        # the key" prompt; it still prompts for an optional passphrase,
        # which is intentional.
        ssh-keygen -t ed25519 -C "$_GIT_USER_EMAIL" -f "$HOME/.ssh/id_ed25519"
        log_success "SSH key generated"
    fi

    local ssh_config_tmp
    # Explicit template: BSD mktemp (macOS) errors on a bare `mktemp` call
    # with no template, unlike GNU mktemp (Linux).
    ssh_config_tmp="$(mktemp "${TMPDIR:-/tmp}/personal-script-ssh-config.XXXXXXXX")"
    cat > "$ssh_config_tmp" <<'EOF'
Host github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519

Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3
EOF
    install_file "$ssh_config_tmp" "$HOME/.ssh/config"
    rm -f "$ssh_config_tmp"
    chmod 600 "$HOME/.ssh/config"

    if ! ssh-add -l >/dev/null 2>&1; then
        eval "$(ssh-agent -s)" >/dev/null
    fi
    ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null || true

    log_info "SSH public key (add at https://github.com/settings/keys if not already added):"
    cat "$HOME/.ssh/id_ed25519.pub"
}
