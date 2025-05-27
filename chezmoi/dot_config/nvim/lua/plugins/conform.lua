return {
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			-- https://www.reddit.com/r/NixOS/comments/1dsvg71/nix_formatter_neovim/
			-- Need to install nixfmt separately https://github.com/NixOS/nixfmt
			formatters_by_ft = {
				nix = { "nixfmt" },
				javascript = { "biome", "biome-organize-imports", "prettier" },
				javascriptreact = { "biome", "biome-organize-imports", "prettier" },
				typescript = { "biome", "biome-organize-imports", "prettier" },
				typescriptreact = { "biome", "biome-organize-imports", "prettier" },
			},
		},
	},
}
