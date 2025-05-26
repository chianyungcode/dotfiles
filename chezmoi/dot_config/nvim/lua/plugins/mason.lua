return {
	{
		"mason-org/mason-lspconfig.nvim", -- Ini yang memberitahu ke nvim-lspconfig mana LSP yang harus dijalankan
		version = "1.32.0",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"templ", -- Go
					"markdown_oxide",
					"ts_ls", -- Kode error diagnostic 'ts'
					"lua_ls",
					"eslint", -- Kode error diagnostic 'typesript-eslint'
					"biome",
					"vtsls",
					"astro",
					"gopls",
				},
				automatic_enable = {
					exclude = {
						"marksman",
						"harper-ls",
						"shellcheck",
					},
				},
			})
		end,
	},

	{
		"mason-org/mason.nvim", -- Ini seperti UI nya di Neovim untuk menginstall berbagai LSP, formatters, linters dsb
		version = "1.11.0",
	},
}
