return {
	{
		"mason-org/mason-lspconfig.nvim", -- Ini yang menmberitahu ke nvim-lspconfig mana LSP yang harus dijalankan
		version = "1.32.0",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"templ",
				},
				automatic_enable = {
					exclude = {
						"marksman",
					},
				},
			})
		end,
	},

	{
		"mason-org/mason.nvim", -- Ini seperti UI nya di Neovim untuk menginstall berbagai LSP, formatters, linters dsb
		version = "1.11.0",
		opts = {
			ensure_installed = {
				"harper-ls",
			},
		},
	},
}
