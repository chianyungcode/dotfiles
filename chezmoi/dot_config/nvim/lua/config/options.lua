-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Comment ini jika ingin menggunakan tiny-inline-diagnostic plugin
-- vim.diagnostic.config({
-- 	virtual_text = false,
-- 	virtual_lines = false,
-- })

vim.opt.spelllang = { "en", "id" }
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Enable this option to avoid conflicts with Prettier. https://www.lazyvim.org/extras/formatting/biome
-- vim.g.lazyvim_prettier_needs_config = true

-- vim.diagnostic.config({
-- 	virtual_text = true,
-- 	virtual_lines = { current_line = true },
-- 	underline = true,
-- 	update_in_insert = false,
-- })
-- vim.opt_local.spell = false
-- vim.opt_global.spell = false
