return {
  -- == Language Server Protocol ==
  {
    "mason-org/mason-lspconfig.nvim", -- Ini yang memberitahu ke nvim-lspconfig mana LSP yang harus dijalankan
    version = "1.32.0", -- Pinning this version because lazyvim doesn't work with mason 2.0
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        -- Yang bisa ditambahkan disini hanya yang memiliki category LSP
        -- Semua dibawah ini dinamakan registries
        "templ", -- An HTML templating language for Go that has great developer tooling.
        "markdown_oxide", -- Markdown: Language server protocol (LSP). Markdown language server with advanced linking support made to be completely compatible with Obsidian; An Obsidian Language Server.
        "ts_ls", -- Javascript, Typescript: Language server protocol (LSP). Kode error diagnostic 'ts'
        "eslint", -- Javascript, Typescript: linters (eslint). Error code: typescript-eslint
        "biome", -- Javascript, Typescript: Language server protocol (LSP), formatters and linters
        "vtsls", -- Javascript, Typescript: Language server protocol (LSP)
        "denols", -- Javascript, Typescript: Language server protocol (LSP), runtime and linters
        "lua_ls", -- Lua: Language server protocol (LSP)
        "tailwindcss",
        "astro",
        "gopls", -- Go: Language server protocol (LSP)
        "html",
        "jsonls", -- JSON: Language server protocol (LSP)
        "nil_ls", -- Nix: Language server protocol (LSP)
        "taplo", -- TOML: Language server protocol (LSP) and formatters
        "yamlls", -- YAML: Language server protocol (LSP)
        "ast_grep",
        "ruff", -- Python: Language server protocol (LSP), linters and formatters
      },
      automatic_enable = {
        exclude = {
          "marksman",
          "harper-ls",
          "shellcheck",
          "prettier",
        },
      },
    },
  },

  -- mason 2.0 problem with lazyvim
  -- https://github.com/LazyVim/LazyVim/issues/6039#issuecomment-2856227817
  -- https://github.com/LazyVim/LazyVim/pull/6053
  {
    "mason-org/mason.nvim", -- Ini seperti UI nya di Neovim untuk menginstall berbagai LSP, formatters, linters dsb
    version = "1.11.0", -- Pinning this version because lazyvim doesn't work with mason 2.0
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- == Formatters ==
  {
    -- References :
    -- https://www.reddit.com/r/NixOS/comments/1dsvg71/nix_formatter_neovim/
    -- Need to install nixfmt separately https://github.com/NixOS/nixfmt
    -- https://medium.com/@lysender/using-biome-with-neovim-and-conform-afcc0ea0524b

    "stevearc/conform.nvim",
    optional = true,
    opts = {
      -- Conform will run the first available formatter
      -- Conform will run multiple formatters sequentially
      formatters_by_ft = { -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#setup
        nix = { "nixfmt" },
        lua = { "stylua" },
        python = { "ruff" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
        javascript = { "biome", "biome-organize-imports", "prettier" },
        javascriptreact = { "biome", "biome-organize-imports", "prettier" },
        typescript = { "biome", "biome-organize-imports", "prettier" },
        typescriptreact = { "biome", "biome-organize-imports", "prettier" },
        yaml = { "yamlfmt", "prettier" },
        -- toml = { "taplo" }, -- Bug when using with taplo, [[rule]] array are ignored when using format on save
        -- Use the "*" filetype to run formatters on all filetypes.
        -- ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },
      },
    },
  },
}
