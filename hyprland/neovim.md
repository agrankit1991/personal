```bash
# install neovim
install nvim

# install lazyvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git 

# install lazygit
install lazygit
```

## Enable Java and Docker support in lazyvim
open :LazyExtras select languages using x which you want to install.

## Enable the Java "Extra"
LazyVim has a built-in extra for Java that sets up nvim-jdtls, debugger support (DAP), and testing.

1. Open your Neovim.
2. Enter the LazyVim extras menu by typing: :LazyExtras
3. Find lang.java in the list.
4. Press x to enable it.
5. Restart Neovim
