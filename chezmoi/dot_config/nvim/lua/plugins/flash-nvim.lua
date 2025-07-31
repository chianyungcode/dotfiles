-- useful youtube video : https://www.youtube.com/watch?v=p_sVgHS2zcA
--
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		modes = {
			search = {
				enabled = true,
			},
			char = {
				jump_labels = true,
			},
		},
		search = {
			multi_window = false,
		},
	},
	-- stylua: ignore
}
