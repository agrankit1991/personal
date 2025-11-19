# Complete Git Configuration Guide for Ubuntu

## 1. Install Git

First, install Git from the Ubuntu repositories:
```bash
sudo apt update
sudo apt install git
```

Or using Nala (for a better experience):
```bash
sudo nala update
sudo nala install git
```

## 2. Basic Git Configuration

Set your identity:
```bash
git config --global user.name "Ankit Agrawal"
git config --global user.email "hiankit+github@gmail.com"
```

## 3. Configure Default Settings

```bash
# Set default branch name to main
git config --global init.defaultBranch main

# Set default editor (choose one):
git config --global core.editor "code --wait"  # For VS Code
# git config --global core.editor "vim"        # For Vim
# git config --global core.editor "nano"       # For Nano

# Configure line endings for Linux
git config --global core.autocrlf input

# Enable colorized output
git config --global color.ui true

# Set pull behavior to avoid conflicts
# git config --global pull.rebase false   # Use merge (default)
git config --global pull.rebase true      # Use rebase
# git config --global pull.ff only        # Only allow fast-forward merges
```

## 4. Configure SSH for GitHub

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "hiankit+github@gmail.com"

# Start ssh-agent in the background
eval "$(ssh-agent -s)"

# Create config file with necessary settings
mkdir -p ~/.ssh
cat > ~/.ssh/config << EOL
Host github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOL
# Host github.com: Applies these settings specifically to GitHub
# AddKeysToAgent yes: Automatically adds SSH keys to the ssh-agent when they're used
# IdentityFile ~/.ssh/id_ed25519: Specifies the default SSH key to use

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# Copy the public key to clipboard (install xclip if needed)
sudo apt install xclip  # or: sudo nala install xclip
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# Alternative if xclip is not available
cat ~/.ssh/id_ed25519.pub
# Then manually copy the output
```

Now add this key to your GitHub account:
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste the key from your clipboard
4. Give it a meaningful title (e.g., "Ankit's Ubuntu Machine")

## 5. Configure Git Aliases

```bash
# Common operations
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"

# Useful log formats
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global alias.lp "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
```

## 6. Configure Git Credentials Helper

```bash
# Install libsecret for secure credential storage
sudo apt install libsecret-1-0 libsecret-1-dev  # or: sudo nala install libsecret-1-0 libsecret-1-dev
sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret

# Configure Git to use libsecret
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
```

## 7. Configure Global .gitignore

```bash
# Create global gitignore file
cat > ~/.gitignore_global << EOL
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

# Tell Git to use this global gitignore file
git config --global core.excludesfile ~/.gitignore_global
```

## 8. Configure Git Message Template

```bash
# Create commit message template
cat > ~/.gitmessage << EOL
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

# Set it as default commit template
git config --global commit.template ~/.gitmessage
# Use git commit to use the template to provide the message
```

## 9. Verify Configuration

Check your configuration:
```bash
# List all configurations
git config --list

# Check specific settings
git config user.name
git config user.email
```

## 10. Testing GitHub Connection

```bash
# Test SSH connection to GitHub
ssh -T git@github.com
```

## 11. Optional: Configure Different Git Configs for Different Directories

If you work on different projects (personal/work), you can create directory-specific configurations:

```bash
# Create a directory-specific gitconfig
mkdir -p ~/Developer/Work
cd ~/Developer/Work
git config --local user.email "your-work-email@company.com"

mkdir -p ~/Developer/Personal
cd ~/Developer/Personal
git config --local user.email "ankitagrawal1991@gmail.com"
```

## 12. Install Additional Git Tools

```bash
# Install gitk - a graphical history viewer
sudo apt install gitk  # or: sudo nala install gitk

# Install git-gui - a GUI for git
sudo apt install git-gui  # or: sudo nala install git-gui

# Install meld - visual diff and merge tool
sudo apt install meld  # or: sudo nala install meld
git config --global merge.tool meld
git config --global diff.tool meld
```

## FAQ
If Git is still asking for username and password despite following the SSH setup, there are a few potential causes and solutions:
First, let's verify if you're using SSH URLs for your repositories instead of HTTPS URLs. This is the most common cause of this issue.
Check your remote URL:
```bash
git remote -v
```
If you see URLs starting with https://, you need to change them to SSH URLs. The URLs should look like:
- HTTPS: https://github.com/username/repo.git (will ask for password)
- SSH: git@github.com:username/repo.git (will use SSH key)
  To change from HTTPS to SSH, use this command:
```bash
git remote set-url origin git@github.com:username/repo.git
```