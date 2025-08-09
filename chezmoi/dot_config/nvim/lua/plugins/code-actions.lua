return {
  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").setup({
        init = function()
          -- Require providers
          require("hover.providers.lsp")
          -- require('hover.providers.gh')
          -- require('hover.providers.gh_user')
          -- require('hover.providers.jira')
          -- require('hover.providers.dap')
          -- require('hover.providers.fold_preview')
          -- require('hover.providers.diagnostic')
          -- require('hover.providers.man')
          -- require('hover.providers.dictionary')
        end,
        preview_opts = {
          border = "single",
        },
        preview_window = false,
        title = true,
        mouse_providers = {
          "LSP",
        },
        mouse_delay = 1000,
      })

      -- Setup keymaps
      vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
      -- vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
      vim.keymap.set("n", "<C-p>", function()
        require("hover").hover_switch("previous")
      end, { desc = "hover.nvim (previous source)" })
      vim.keymap.set("n", "<C-n>", function()
        require("hover").hover_switch("next")
      end, { desc = "hover.nvim (next source)" })

      -- Mouse support
      vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
      vim.o.mousemoveevent = true
    end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    enabled = true,
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    -- opts = {
    -- 	presets = "ghost",
    -- },
    config = function()
      vim.opt.updatetime = 100
      vim.diagnostic.config({ virtual_text = false })
      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f76464" })
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f7bf64" })
      vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#64bcf7" })
      vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#64f79d" })
      require("tiny-inline-diagnostic").setup({
        -- presets = "amongus",
        options = {
          multilines = true,
          -- multiple_diag_under_cursor = true,
          show_all_diags_on_cursorline = false,
          virt_texts = {
            -- Priority for virtual text display
            priority = 3000,
          },
        },
        blend = {
          factor = 0.1,
        },
        signs = {
          diag = "ඞ", -- Ini di copy dari folder github nya manual di https://github.com/rachartier/tiny-inline-diagnostic.nvim/blob/main/lua/tiny-inline-diagnostic/presets.lua
        },
      })
    end,
  },
  {
    "rachartier/tiny-code-action.nvim",
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
