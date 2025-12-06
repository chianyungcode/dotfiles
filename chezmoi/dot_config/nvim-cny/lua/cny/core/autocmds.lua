-- Always hard wrap at 80 characters in every file
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = function()
		vim.opt_local.textwidth = 80 -- set wrap width
		vim.opt_local.formatoptions:append("t") -- wrap text in insert
		vim.opt_local.smartindent = false -- avoid indenting wrapped lines
	end,
})
