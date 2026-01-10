return {
  -- lazy.nvim
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- kode type dibawah adalah agar adanya completion, jika dihapus maka completion akan hilang
  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    scroll = {
      enabled = false,
    },
    -- disable snacks.indent because i prefer using blink.indent for better performance
    indent = {
      enabled = true,
      -- indent = {
      --   char = "┃",
      -- },
      -- scope = {
      --   char = "┃",
      -- },
      animate = {
        enabled = false,
      },
    },
    styles = {
      snacks_image = {
        relative = "cursor",
        border = true,
        focusable = false,
        backdrop = false,
        row = 2,
        col = 2,
        -- width/height are automatically set by the image size unless specified below
      },
    },
    image = {
      doc = {
        -- enable image viewer for documents
        -- a treesitter parser must be available for the enabled languages.
        enabled = true,
        -- render the image inline in the buffer
        -- if your env doesn't support unicode placeholders, this will be disabled
        -- takes precedence over `opts.float` on supported terminals
        inline = false,
        -- render the image in a floating window
        -- only used if `opts.inline` is disabled, if `float` set to true then `inline` need to set to false
        float = true,
        max_width = 60,
        max_height = 30,
      },
    },
    -- Snacks.picker() ini adalah snacks.picker custom configuration
    picker = {
      layout = {
        preset = "ivy",
      },
      sources = {
        -- NOTE: showing hidden and ignore files
        -- files = { ignored = true, hidden = true },
        -- grep = { ignored = true, hidden = true },
        -- grep_word = { ignored = true, hidden = true },
        -- grep_buffers = { ignored = true, hidden = true },

        explorer = {
          -- NOTE: showing hidden and ignore files
          -- ignored = true,
          -- hidden = true,

          -- uncomment this if want preview on select
          -- auto_close = true,
          -- layout = {
          --   preset = "sidebar", -- other options is "ivy", "select"
          --   preview = "main",
          -- },

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
    -- terminal = {
    --   win = {
    --     style = "float",
    --     width = 0.8, -- 90% lebar layar
    --     height = 0.8, -- 90% tinggi layar
    --     border = "rounded",
    --     title = "Terminal",
    --     title_pos = "center",
    --     wo = {
    --       winbar = "",
    --     },
    --   },
    -- },
  },
}
