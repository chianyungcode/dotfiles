-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Related to plugin wormhole
vim.keymap.set("n", "<leader>wl", "<Plug>(WormholeLabels)", { desc = "Wormhole Labels" })
vim.keymap.set("n", "<Esc>", "<Plug>(WormholeCloseLabels)", { desc = "Wormhole Close Labels" })
-- vim.keymap.set("n", "<leader>e", function() end, { desc = "Chian" })

-- Syntax
-- vim.keymap.set("mode-vim", "keymaps", "command / function", { desc = "Wormhole Close Labels" })
