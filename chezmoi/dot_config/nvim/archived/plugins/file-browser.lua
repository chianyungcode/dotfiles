if true then
  return {}
end

return {
  "grecodavide/file_browser.nvim",
  dependencies = {
    "echasnovski/mini.icons", -- to display file icons
  },
  lazy = true,
  config = function()
    require("file_browser").setup({
      width_scale = 0.9,
      height_scale = 0.8,
      mappings = {
        {
          mode = "i",
          lhs = "<C-r>",
          callback = "rename",
        },
      },
    })
  end,
  -- I like to have <leader>fe to open file browser in the same path as current file, and <leader>fE in the CWD
  keys = {
    {
      "<leader>fe",
      function()
        require("file_browser").open(vim.fn.expand("%:p:h"))
      end,

      desc = "[F]ile [E]xplorer current file",
    },
    {
      "<leader>fE",
      function()
        require("file_browser").open()
      end,

      desc = "[F]ile [E]xplorer CWD",
    },
  },
}
