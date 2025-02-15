-- if true then
-- 	return {}
-- end

return {
	-- { "killitar/obscure.nvim" },
	-- {
	-- 	"oxfist/night-owl.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- },

	{ "yorumicolors/yorumi.nvim", enabled = false, lazy = false, priority = 1000 },
	-- { "sainnhe/sonokai", lazy = false, priority = 1000 },
	-- { "mellow-theme/mellow.nvim", lazy = false, priority = 1000 },
	-- { "Yazeed1s/minimal.nvim", lazy = false, priority = 1000 },
	-- Lazy
	-- { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
	-- {
	-- 	"philosofonusus/morta.nvim",
	-- 	name = "morta",
	-- 	priority = 1000,
	-- 	lazy = false,
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		enabled = false,
		-- config = function()
		-- 	require("catppuccin").setup({
		-- 		transparent_background = true, -- disables setting the background color.
		-- 	})
		-- end,
	},
	-- {
	-- 	"vague2k/vague.nvim",
	-- 	config = function()
	-- 		require("vague").setup({
	-- 			-- optional configuration here
	-- 		})
	-- 	end,
	-- },
	{
		"dgox16/oldworld.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("oldworld").setup({
				variants = "default",
			})
		end,
	},
	-- {
	-- 	"ricardoraposo/nightwolf.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {
	-- 		theme = "dark-gray",
	-- 	},
	-- },
	-- {
	-- 	"rebelot/kanagawa.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("kanagawa").setup({
	-- 			theme = "lotus",
	-- 		})
	-- 	end,
	-- },
	{
		"folke/tokyonight.nvim",
		enabled = false,
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	{
		"olimorris/onedarkpro.nvim",
		enabled = false,
		priority = 1000, -- Ensure it loads first
		config = function()
			require("onedarkpro").setup({
				options = {
					transparency = true,
				},
			})
		end,
	},
	{
		"nickkadutskyi/jb.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "oldworld",
		},
	},
}
