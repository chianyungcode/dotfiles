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

-- Uncomment the code below, if only use prettier if the config file `.prettierrc` or `prettier.json` exist in the root project directory
-- vim.g.lazyvim_prettier_needs_config = true

-- Uncomment this if want to show cool inline diagnostic
-- vim.diagnostic.config({
--   virtual_text = true,
--   virtual_lines = { current_line = true },
--   underline = true,
--   update_in_insert = false,
-- })

-- vim.opt_local.spell = false
-- vim.opt_global.spell = false
