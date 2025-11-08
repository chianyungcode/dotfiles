return {
  {
    "gbprod/substitute.nvim",
    enabled = false,
    config = function()
      require("substitute").setup({})

      -- masih bentrok dengan flash.nvim masih bingung untuk keymapping yang sesuai nantinya
      -- Lua
      vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
      vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
      vim.keymap.set("n", "Z", require("substitute").eol, { noremap = true }) -- end of line
      vim.keymap.set("x", "z", require("substitute").visual, { noremap = true })

      vim.keymap.set("n", "sx", require("substitute.exchange").operator, { noremap = true })
      vim.keymap.set("n", "sxx", require("substitute.exchange").line, { noremap = true })
      vim.keymap.set("x", "X", require("substitute.exchange").visual, { noremap = true })
      vim.keymap.set("n", "sxc", require("substitute.exchange").cancel, { noremap = true })
    end,
  },

  -- https://github.com/gbprod/yanky.nvim
  -- DESC: add more capabilities to yank
  {
    "gbprod/yanky.nvim",
    enabled = false,
    config = function()
      require("yanky").setup({})

      vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
      vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)") -- ctrl + shift + p
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)") -- ctrl + shift + n
    end,
  },

  -- https://github.com/Goose97/timber.nvim
  -- DESC: Neovim plugin to quickly insert log statements and capture log output
  {
    "Goose97/timber.nvim",
    enabled = false,
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("timber").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  -- https://github.com/m4xshen/hardtime.nvim
  -- DESC: Break bad habits, master Vim motions
  {
    "m4xshen/hardtime.nvim",
    enabled = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  {
    "atiladefreitas/lazyclip",
    enabled = false,
    config = function()
      require("lazyclip").setup({
        -- your custom config here (optional)
      })
    end,
    keys = {
      { "Cw", desc = "Open Clipboard Manager" },
    },
    -- Optional: Load plugin when yanking text
    event = { "TextYankPost" },
  },
}
