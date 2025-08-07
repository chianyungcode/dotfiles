return {
  "zaldih/themery.nvim",
  enabled = false,
  lazy = false,
  config = function()
    require("themery").setup({
      -- add the config here
      themes = { "catppuccin-mocha", "catppuccin-machiato", "tokyonight", "night-owl" },
    })
  end,
}
