return {
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			-- https://www.reddit.com/r/NixOS/comments/1dsvg71/nix_formatter_neovim/
			-- Need to install nixfmt separately https://github.com/NixOS/nixfmt
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}
