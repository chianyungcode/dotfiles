-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Related to plugin wormhole
-- vim.keymap.set("n", "<leader>wl", "<Plug>(WormholeLabels)", { desc = "Wormhole Labels" })
-- vim.keymap.set("n", "<Esc>", "<Plug>(WormholeCloseLabels)", { desc = "Wormhole Close Labels" })
-- vim.keymap.set("n", "<leader>e", function() end, { desc = "Chian" })

-- Related to plugin 'tiny-code-action'
vim.keymap.set("n", "<leader>cb", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true })

-- Fix keymap behavior:
-- When pressing '?' and 'n', the search should move to the top (previous match),
-- not to the bottom (next match).
-- This adjusts the search direction to be consistent with expected behavior.
vim.keymap.set("n", "n", "n", { noremap = true })
vim.keymap.set("n", "N", "N", { noremap = true })

-- Terminal: hide current terminal window instead of opening a new one/splitting
vim.keymap.set("t", "<C-/>", function()
  if vim.bo.buftype == "terminal" then
    vim.api.nvim_win_hide(0)
  end
end, { noremap = true, silent = true, desc = "Hide terminal" })
vim.keymap.set("t", "<C-_>", function()
  if vim.bo.buftype == "terminal" then
    vim.api.nvim_win_hide(0)
  end
end, { noremap = true, silent = true, desc = "Hide terminal" })

-- Syntax
-- vim.keymap.set("mode-vim", "keymaps", "command / function", { desc = "Wormhole Close Labels" })
