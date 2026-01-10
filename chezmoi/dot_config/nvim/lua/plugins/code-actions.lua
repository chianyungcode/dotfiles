return {
  --
  {
    "stevearc/quicker.nvim",
    ft = "qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
  -- https://github.com/lewis6991/hover.nvim
  -- DESC: fancy hover for neovim
  {
    "lewis6991/hover.nvim",
    enabled = true,
    config = function()
      require("hover").config({
        --- List of modules names to load as providers.
        --- @type (string|Hover.Config.Provider)[]
        providers = {
          "hover.providers.diagnostic",
          "hover.providers.lsp",
          "hover.providers.dap",
          "hover.providers.man",
          "hover.providers.dictionary",
          -- Optional, disabled by default:
          -- 'hover.providers.gh',
          -- 'hover.providers.gh_user',
          -- 'hover.providers.jira',
          -- 'hover.providers.fold_preview',
          -- 'hover.providers.highlight',
        },
        preview_opts = {
          border = "single",
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
        mouse_providers = {
          "hover.providers.lsp",
        },
        mouse_delay = 1000,
      })

      -- Setup keymaps
      vim.keymap.set("n", "K", function()
        require("hover").open()
      end, { desc = "hover.nvim (open)" })

      vim.keymap.set("n", "gK", function()
        require("hover").enter()
      end, { desc = "hover.nvim (enter)" })

      vim.keymap.set("n", "<C-p>", function()
        require("hover").switch("previous")
      end, { desc = "hover.nvim (previous source)" })

      vim.keymap.set("n", "<C-n>", function()
        require("hover").switch("next")
      end, { desc = "hover.nvim (next source)" })

      -- Mouse support
      -- vim.keymap.set("n", "<MouseMove>", function()
      --   require("hover").mouse()
      -- end, { desc = "hover.nvim (mouse)" })

      vim.o.mousemoveevent = true
    end,
  },

  {
    -- A bit buggy, sometimes diagnostic not showing
    "rachartier/tiny-inline-diagnostic.nvim",
    enabled = false,
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end,
  },

  {
    "rachartier/tiny-code-action.nvim",
    enabled = false,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "folke/snacks.nvim",
        opts = {
          terminal = {},
        },
      },
    },
    event = "LspAttach",
    opts = {
      picker = "snacks",
      backend = "vim",
      backend_opts = {
        delta = {
          -- Header from delta can be quite large.
          -- You can remove them by setting this to the number of lines to remove
          header_lines_to_remove = 4,

          -- The arguments to pass to delta
          -- If you have a custom configuration file, you can set the path to it like so:
          -- args = {
          --     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
          -- }
          args = {
            "--line-numbers",
          },
        },
        difftastic = {
          header_lines_to_remove = 1,

          -- The arguments to pass to difftastic
          args = {
            "--color=always",
            "--display=inline",
            "--syntax-highlight=on",
          },
        },
        diffsofancy = {
          header_lines_to_remove = 4,
        },
      },

      -- The icons to use for the code actions
      -- You can add your own icons, you just need to set the exact action's kind of the code action
      -- You can set the highlight like so: { link = "DiagnosticError" } or  like nvim_set_hl ({ fg ..., bg..., bold..., ...})
      signs = {
        quickfix = { "", { link = "DiagnosticWarning" } },
        others = { "", { link = "DiagnosticWarning" } },
        refactor = { "", { link = "DiagnosticInfo" } },
        ["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
        ["refactor.extract"] = { "", { link = "DiagnosticError" } },
        ["source.organizeImports"] = { "", { link = "DiagnosticWarning" } },
        ["source.fixAll"] = { "󰃢", { link = "DiagnosticError" } },
        ["source"] = { "", { link = "DiagnosticError" } },
        ["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
        ["codeAction"] = { "", { link = "DiagnosticWarning" } },
      },
    },
  },
}
