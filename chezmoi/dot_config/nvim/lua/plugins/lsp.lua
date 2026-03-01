return {
  -- == Language Server Protocol ==
  {
    "mason-org/mason-lspconfig.nvim", -- Ini yang memberitahu ke nvim-lspconfig mana LSP yang harus dijalankan
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Only LSP can be listed here, for formatters and linters provide in mason.nvim plugin
      ensure_installed = {
        "ast_grep", -- Generic AST-based code search/rewrite
        "astro", -- Astro
        "biome", -- JavaScript / TypeScript
        -- "copilot-language-server", -- Copilot NES (next edit suggestion)
        -- "denols", -- JavaScript / TypeScript (Deno)
        "eslint", -- JavaScript / TypeScript (linting)
        "gopls", -- Go
        "html", -- HTML
        "jsonls", -- JSON
        "lua_ls", -- Lua
        "markdown_oxide", -- Markdown
        "nil_ls", -- Nix
        "prismals", -- Prisma
        "ruff", -- Python
        "sqls", -- SQL
        -- "tailwindcss", -- Tailwind CSS
        -- "taplo", -- TOML (don't install with mason because can giving an error on Neovim LSP)
        "templ", -- Templ (Go HTML templating)
        "tombi", -- TOML
        "ts_ls", -- JavaScript / TypeScript
        "yamlls", -- YAML
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

  {
    "mason-org/mason.nvim", -- Ini seperti UI nya di Neovim untuk menginstall berbagai LSP, formatters, linters dsb
    opts = {
      ensure_installed = {
        -- "sqruff", -- SQL Formatter
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
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- Disable default hover keymap to avoid conflict with hover.lua
            { "K", false },
          },
        },
      },
    },
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
