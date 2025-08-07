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
      sources = {
        -- files = { ignored = true, hidden = true },
        -- grep = { ignored = true, hidden = true },
        -- grep_word = { ignored = true, hidden = true },
        -- grep_buffers = { ignored = true, hidden = true },
        explorer = {
          -- ignored = true,
          -- hidden = true,
          layout = {
            preset = "sidebar", -- other options is "ivy", "select"
            layout = {
              position = "left",
            },
          },
          win = {
            list = {
              wo = {
                number = true, -- https://github.com/folke/snacks.nvim/discussions/1150#discussioncomment-12192637
                relativenumber = true,
              },
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
