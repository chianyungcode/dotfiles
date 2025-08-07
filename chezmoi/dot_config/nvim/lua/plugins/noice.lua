return
-- lazy.nvim
{
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
    views = {
      -- This sets for cmdline position
      cmdline_popup = {
        position = {
          row = "40%",
          col = "50%",
        },
      },
    },
  },
}
