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
					-- Semua dibawah ini dinamakan registries
					"templ", -- Go
					"markdown_oxide",
					"ts_ls", -- Kode error diagnostic 'ts'
					"lua_ls",
					"eslint", -- Kode error diagnostic 'typesript-eslint'
					"biome",
					"vtsls",
					"tailwindcss",
					"astro",
					"gopls",
					"html",
					"jsonls",
					"denols",
					"nil_ls",
					"taplo",
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
