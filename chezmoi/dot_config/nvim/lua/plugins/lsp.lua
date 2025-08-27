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
      -- Only LSP can be listed here, for formatters and linters provide in mason.nvim plugin
      ensure_installed = {
        -- Yang bisa ditambahkan disini hanya yang memiliki category LSP
        -- Semua dibawah ini dinamakan registries
        "templ", -- An HTML templating language for Go that has great developer tooling.
        "markdown_oxide", -- Markdown: Language server protocol (LSP). Markdown language server with advanced linking support made to be completely compatible with Obsidian; An Obsidian Language Server.
        "ts_ls", -- Javascript, Typescript: Language server protocol (LSP). Kode error diagnostic 'ts'
        "eslint", -- Javascript, Typescript: Language server protocol (LSP). Linters (eslint). Error code: typescript-eslint
        "biome", -- Javascript, Typescript: Language server protocol (LSP), formatters and linters
        -- "denols", -- Javascript, Typescript: Language server protocol (LSP), runtime and linters
        "lua_ls", -- Lua: Language server protocol (LSP)
        "tailwindcss",
        "astro",
        "gopls", -- Go: Language server protocol (LSP)
        "html",
        "jsonls", -- JSON: Language server protocol (LSP)
        "nil_ls", -- Nix: Language server protocol (LSP)
        -- "taplo", -- TOML: Language server protocol (LSP) and formatters
        "yamlls", -- YAML: Language server protocol (LSP)
        "ast_grep",
        "ruff", -- Python: Language server protocol (LSP), linters and formatters
        "prismals", -- prisma orm
        -- "sqlls", -- SQL LSP
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
      ensure_installed = {
        "sqlfluff", -- SQL Linter
      },
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- disable a keymap
      -- Ini adalah default untuk hover kode, keymap ini saya disable karena berbenturan dengan plugin hover.lua . Sebenarnya sama saja fungsinya sama-sama untuk menghover suatu kode, tetapi dengan plugin bisa di customize lebih lagi.
      keys[#keys + 1] = { "K", false }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = "LazyFile",
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
    keys = {
      {
        "<leader>ut",
        function()
          local tsc = require("treesitter-context")
          tsc.toggle()
          if LazyVim.inject.get_upvalue(tsc.toggle, "enabled") then
            LazyVim.info("Enabled Treesitter Context", { title = "Option" })
          else
            LazyVim.warn("Disabled Treesitter Context", { title = "Option" })
          end
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
}
