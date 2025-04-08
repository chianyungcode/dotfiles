return {
	"leath-dub/snipe.nvim",
	enabled = false,
	keys = {
		{
			"gb",
			function()
				require("snipe").open_buffer_menu()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
	--- @type snipe.DefaultConfig
	opts = {
		ui = {
			position = "center",
			open_win_override = {
				border = "rounded",
			},
			text_align = "file-first",
		},
		hints = {
			dictionary = "asdflewcmpghio",
		},
	},
}
