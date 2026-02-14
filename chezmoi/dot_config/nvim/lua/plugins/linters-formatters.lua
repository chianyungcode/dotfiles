return {
  {
    -- References :
    -- https://www.reddit.com/r/NixOS/comments/1dsvg71/nix_formatter_neovim/
    -- Need to install nixfmt separately https://github.com/NixOS/nixfmt
    -- https://medium.com/@lysender/using-biome-with-neovim-and-conform-afcc0ea0524b

    "stevearc/conform.nvim",
    optional = true,
    opts = {
      -- Conform will execute the first available formatter, followed by the next ones sequentially.
      -- If multiple formatters are defined and available (cli are installed), each will run in order without any visible transition.
      -- For example, if the first formatter sets indentation to 2 and the second sets it to 6,
      -- the final result will have an indentation of 6 — you won’t see the intermediate state of 2-space indentation.

      -- Syntax : <LANGUAGE> = { "<first_formatter>", "<second_formatter>" }
      -- Example : javascript = { "biome", "prettier" }, // This will run "biome" first, and after that will run "prettier"

      formatters_by_ft = { -- https://github.com/stevearc/conform.nvim?tab=readme-ov-file#setup
        nix = { "alejandra" },
        lua = { "stylua" },
        python = { "ruff" },
        rust = { "rustfmt" },
        go = { "gofmt" },
        javascript = { "biome", "biome-organize-imports" },
        javascriptreact = { "biome", "biome-organize-imports" },
        typescript = { "biome", "biome-organize-imports" },
        typescriptreact = { "biome", "biome-organize-imports" },
        yaml = { "yamlfmt" }, -- Using custom formatters, because yamlfmt default with mason bug with indentation that set in .yamlfmt in root of working directory
        toml = { "taplo" }, -- Using custom formatters, to prevent use default config for taplo in conform that can causing bug
        json = { "biome" },
        jsonc = { "biome" },
        sql = { "sqruff" },
        -- toml = { "taplo" }, -- Bug when using with default `taplo`, [[rule]] array are ignored when using format on save
        -- Use the "*" filetype to run formatters on all filetypes.
        -- ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },
      },
    },
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = true,
    -- Custom formatters and overrides for built-in formatters
    formatters = {
      taplo_fmt = {
        command = "taplo", -- CLI taplo
        args = { "format", "-" }, -- "-" supaya baca dari stdin
        stdin = true, -- kirim isi file lewat stdin
        cwd = require("conform.util").root_file({ ".taplo.toml", "taplo.toml" }), -- opsional, kalau mau deteksi root
        require_cwd = false, -- kalau root nggak ketemu tetap jalan
      },
    },
  },
  {
    -- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file
    -- https://github.com/DavidAnson/markdownlint-cli2
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        -- https://github.com/LazyVim/LazyVim/discussions/4094#discussioncomment-10178217
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            os.getenv("HOME") .. ".config/nvim/lua/cfg_linters/.markdownlint.yaml",
            "--",
          },
        },
      },
    },
  },
}
