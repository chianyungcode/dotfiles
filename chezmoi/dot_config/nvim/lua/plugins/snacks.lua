return {
	-- lazy.nvim
	"folke/snacks.nvim",
	-- kode type dibawah adalah agar adanya completion, jika dihapus maka completion akan hilang
	---@type snacks.Config
	opts = {
		-- Snacks.picker() ini adalah snacks.picker custom configuration
		picker = {
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
	},
}
