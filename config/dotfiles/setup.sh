# Copy or create symbolic links for dotfiles
# -f flag is for force create if a symlink already exists
ln -sf $PWD/.zshrc ~/.zshrc
ln -sf $PWD/.gitignore ~/.gitignore
ln -sf $PWD/.p10k.zsh ~/.p10k.zsh