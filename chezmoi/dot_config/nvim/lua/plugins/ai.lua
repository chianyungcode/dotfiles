return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
      { "folke/snacks.nvim", opts = { input = { enabled = true } } },
    },
    config = function()
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true

      -- Recommended keymaps
      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })
      vim.keymap.set("n", "<leader>oA", function()
        require("opencode").ask()
      end, { desc = "Ask opencode" })
      vim.keymap.set("n", "<leader>oa", function()
        require("opencode").ask("@cursor: ")
      end, { desc = "Ask opencode about this" })
      vim.keymap.set("v", "<leader>oa", function()
        require("opencode").ask("@selection: ")
      end, { desc = "Ask opencode about selection" })
      vim.keymap.set("n", "<leader>on", function()
        require("opencode").command("session_new")
      end, { desc = "New opencode session" })
      vim.keymap.set("n", "<leader>oy", function()
        require("opencode").command("messages_copy")
      end, { desc = "Copy last opencode response" })
      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("messages_half_page_up")
      end, { desc = "Messages half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("messages_half_page_down")
      end, { desc = "Messages half page down" })
      vim.keymap.set({ "n", "v" }, "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select opencode prompt" })

      -- Example: keymap for custom prompt
      vim.keymap.set("n", "<leader>oe", function()
        require("opencode").prompt("Explain @cursor and its context")
      end, { desc = "Explain this code" })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    dependencies = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
  },
  {
    "folke/sidekick.nvim",
    enabled = true,
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
          -- Or to select only installed tools:
          -- require("sidekick.cli").select({ filter = { installed = true } })
        end,
        desc = "Sidekick Select CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "Sidekick Opencode Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "grok", focus = true })
        end,
        desc = "Sidekick Grok Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        desc = "Sidekick Ask Prompt",
        mode = { "n", "v" },
      },
    },
  },
}
