return {
  "akinsho/bufferline.nvim",
  enabled = true,
  keys = {
    {
      "<A-1>",
      "<cmd>BufferLineGoToBuffer 1<CR>",
    },
    {
      "<A-2>",
      "<cmd>BufferLineGoToBuffer 2<CR>",
    },
    {
      "<A-3>",
      "<cmd>BufferLineGoToBuffer 3<CR>",
    },
    {
      "<A-4>",
      "<cmd>BufferLineGoToBuffer 4<CR>",
    },
    {
      "<A-5>",
      "<cmd>BufferLineGoToBuffer 5<CR>",
    },
    {
      "<A-6>",
      "<cmd>BufferLineGoToBuffer 6<CR>",
    },
    {
      "<A-7>",
      "<cmd>BufferLineGoToBuffer 7<CR>",
    },
    {
      "<A-8>",
      "<cmd>BufferLineGoToBuffer 8<CR>",
    },
    {
      "<A-9>",
      "<cmd>BufferLineGoToBuffer 9<CR>",
    },
  },
  config = function()
    require("bufferline").setup({
      options = {
        numbers = function(opts)
          return string.format("%s", opts.ordinal)
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    })
  end,
}
