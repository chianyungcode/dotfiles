return {
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
  {
    "atiladefreitas/lazyclip",
    enabled = true,
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
