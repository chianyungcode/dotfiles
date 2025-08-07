-- Similar with mini.surround, nvim-surround.
return {
  "NStefan002/visual-surround.nvim",
  enabled = false,
  config = function()
    require("visual-surround").setup({
      -- your config
    })
    -- [optional] custom keymaps
  end,
}
