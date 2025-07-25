--
-- https://github.com/meuter/lualine-so-fancy.nvim
return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"meuter/lualine-so-fancy.nvim",
	},
	opts = {
		options = {
			-- theme = "seoul256",
			component_separators = { left = "│", right = "│" },
			section_separators = { left = "", right = "" },
			globalstatus = true,
			refresh = {
				statusline = 100,
			},
		},
		sections = {
			lualine_a = {
				{ "fancy_mode", width = 3 },
			},
			lualine_b = {
				{ "fancy_branch" },
				-- { "fancy_diff" }, -- showing the diff for text added, modified and removed
			},
			lualine_c = {
				{ "filename", path = 4 }, -- path = 4 (only showing path for the filename and parent directory, not the entire path, the option is 0,1,2,3,4)
			},
			lualine_x = {
				{ "fancy_macro" },
				{ "fancy_diagnostics" },
				{ "fancy_searchcount" },
				-- { "fancy_location" }, -- location of the current cursor -> $line_number | $character_position_number
			},
			lualine_y = {
				-- { "fancy_filetype", ts_icon = "" }, -- Showing filetype for the current buffer
				{},
			},
			lualine_z = {
				{ "fancy_lsp_servers" },
			},
		},
	},
}
