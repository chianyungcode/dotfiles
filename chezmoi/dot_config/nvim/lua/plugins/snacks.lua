return {
	-- lazy.nvim
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	-- kode type dibawah adalah agar adanya completion, jika dihapus maka completion akan hilang
	---@type snacks.Config
	opts = {
		-- Snacks.picker() ini adalah snacks.picker custom configuration
		picker = {
			sources = {
				explorer = {},
			},
			formatters = {
				file = {
					filename_first = true,
				},
			},
		},
		terminal = {
			win = {
				wo = {
					winbar = "",
				},
			},
		},
		explorer = {
			enabled = true,
		},
	},
	keys = {
		{
			"<leader>ee",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
}
