-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- SUPER+C inside a terminal Neovim.
--
-- keyd rewrites SUPER+C to Ctrl+Insert system-wide (arch/cosmic/setup.sh),
-- and Ghostty's ctrl+insert binding is marked `performable:`, so when there
-- is no terminal mouse-selection to copy the key falls through to Neovim and
-- lands on these maps. Without them SUPER+C does nothing here, because a
-- Neovim visual selection is invisible to the terminal.
--
-- Paste needs no mapping: SUPER+V reaches Ghostty as Shift+Insert, which
-- pastes as a bracketed paste, and Neovim inserts that literally rather than
-- executing it as commands — so it behaves in normal mode too.
vim.keymap.set("v", "<C-Insert>", '"+y', { desc = "Copy selection to clipboard" })
vim.keymap.set("n", "<C-Insert>", '"+yy', { desc = "Copy line to clipboard" })
