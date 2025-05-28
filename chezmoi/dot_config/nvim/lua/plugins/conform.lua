-- Lightweight yet powerful formatter plugin for Neovim
return {
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			-- https://www.reddit.com/r/NixOS/comments/1dsvg71/nix_formatter_neovim/
			-- Need to install nixfmt separately https://github.com/NixOS/nixfmt

			-- https://medium.com/@lysender/using-biome-with-neovim-and-conform-afcc0ea0524b
			formatters_by_ft = { -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#setup
				nix = { "nixfmt" },
				-- javascript = { "biome", "biome-organize-imports", "prettier" },
				-- javascriptreact = { "biome", "biome-organize-imports", "prettier" },
				-- typescript = { "biome", "biome-organize-imports", "prettier" },
				-- typescriptreact = { "biome", "biome-organize-imports", "prettier" },
			},
		},
	},
}
