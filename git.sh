#!/bin/bash

# Git Setup Script
# This script configures Git with user information, aliases, and SSH keys

set -e  # Exit on error

echo "Setting up Git configuration..."

# Create Git config directory
mkdir -p ~/.config/git
touch ~/.config/git/config

# Configure user information
git config --global user.name "Ankit Agrawal"
git config --global user.email "hiankit@zohomail.in"

# Configure Git behavior
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global color.ui true
git config --global pull.rebase true

# Configure Git aliases
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global alias.lp "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"

# Create global gitignore file
cat > ~/.config/git/.gitignore << 'EOL'
# Linux system files
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# IDE specific files
.idea/
.vscode/
*.sublime-workspace
*.sublime-project

# Node.js
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log

# Python
*.py[cod]
__pycache__/
*.so
.env
venv/
.env/

# Java
*.class
*.jar
*.war
target/
EOL

# Create commit message template
cat > ~/.config/git/.gitmessage << 'EOL'
# <type>: <subject>
# <body>
# <footer>

# Types:
#   feat     (new feature)
#   fix      (bug fix)
#   docs     (changes to documentation)
#   style    (formatting, missing semi colons, etc; no code change)
#   refactor (refactoring production code)
#   test     (adding missing tests, refactoring tests)
#   chore    (updating grunt tasks etc; no production code change)

# Subject should be no greater than 50 characters
# Body should be wrapped at 72 characters
EOL

# Configure gitignore and commit template
git config --global core.excludesfile ~/.config/git/.gitignore
git config --global commit.template ~/.config/git/.gitmessage

echo "Git configuration complete!"
echo ""

# SSH key setup
echo "Setting up SSH key for GitHub..."
echo "Press Enter to accept default file location, or Ctrl+C to cancel SSH key generation"

ssh-keygen -t ed25519 -C "hiankit@zohomail.in"

# Create SSH config directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create SSH config file
cat > ~/.ssh/config << 'EOL'
Host github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOL

chmod 600 ~/.ssh/config

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo ""
echo "========================================="
echo "Setup complete! Here's your SSH public key:"
echo "Copy this key and add it to your GitHub account at:"
echo "https://github.com/settings/keys"
echo "========================================="
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "========================================="