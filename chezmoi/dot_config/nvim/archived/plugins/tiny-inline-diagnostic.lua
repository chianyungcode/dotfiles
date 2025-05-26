if true then
	return {}
end

return {
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		-- opts = {
		-- 	presets = "ghost",
		-- },
		config = function()
			vim.opt.updatetime = 100
			vim.diagnostic.config({ virtual_text = false })
			-- vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f76464" })
			-- vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f7bf64" })
			-- vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#64bcf7" })
			-- vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#64f79d" })
			require("tiny-inline-diagnostic").setup({
				-- presets = "amongus",
				options = {
					multilines = true,
					-- multiple_diag_under_cursor = true,
					show_all_diags_on_cursorline = false,
				},
				blend = {
					factor = 0.1,
				},
				signs = {
					diag = "ඞ", -- Ini di copy dari folder github nya manual di https://github.com/rachartier/tiny-inline-diagnostic.nvim/blob/main/lua/tiny-inline-diagnostic/presets.lua
				},
			})
		end,
	},
}
