-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- disable spell checking in markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.spell = false
	end,
})
