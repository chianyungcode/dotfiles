return {
  -- lazy.nvim
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- kode type dibawah adalah agar adanya completion, jika dihapus maka completion akan hilang
  ---@type snacks.Config
  opts = {
    -- Snacks.picker() ini adalah snacks.picker custom configuration
    picker = {
      ui_select = false,
      layout = {
        preset = "ivy",
      },
      sources = {
        -- files = { ignored = true, hidden = true },
        -- grep = { ignored = true, hidden = true },
        -- grep_word = { ignored = true, hidden = true },
        -- grep_buffers = { ignored = true, hidden = true },
        explorer = {
          -- ignored = true,
          -- hidden = true,
          auto_close = true,

          layout = {
            -- preset = "sidebar", -- other options is "ivy", "select"
            preview = "main",
            layout = {
              position = "left",
              box = "horizontal",
              width = 0.2,
              height = 0.2,
              {
                box = "vertical",
                border = "rounded",
                title = "{source} {live} {flags}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", border = "rounded", width = 0.7, title = "{preview}" },
            },
          },
          win = {
            list = {
              -- wo = {
              --   number = true, -- https://github.com/folke/snacks.nvim/discussions/1150#discussioncomment-12192637
              --   relativenumber = true,
              -- },
            },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true,
        },
      },
      -- Hapus toggles dan win jika ingin kembali ke default yang mana yang toggle_hidden pada snacks.picker menekan alt-h, ini saya modifikasi karena bertabrakan dengan aerospace
      toggles = {
        hidden = "u",
      },
      win = {
        input = {
          keys = {
            ["<a-u>"] = { "toggle_hidden", mode = { "i", "n" } },
          },
        },
      },
    },
    terminal = {
      win = {
        wo = {
          winbar = "",
        },
      },
    },
  },
}
