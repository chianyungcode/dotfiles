-- For saving session with <leader>qs
return {
	-- Lua
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		enabled = true,
		opts = {
			-- add any custom options here
		},
	},
}
