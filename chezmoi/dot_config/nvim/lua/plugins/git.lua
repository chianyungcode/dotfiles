return {
  {
    -- Displays a sign git next to line numbers
    "lewis6991/gitsigns.nvim",
    enabled = true,
    config = function()
      require("gitsigns").setup({
        current_line_blame_opts = {
          virt_text = true,
          virt_text_priority = 100,
          delay = 300,
        },
        signs = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signs_staged = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      })
    end,
  },
  {
    -- Menampilkan inline blame out of the box secara default
    "tanvirtin/vgit.nvim",
    enabled = false,
    branch = "v1.0.x",
    -- or               , tag = 'v1.0.2',
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    -- Lazy loading on 'VimEnter' event is necessary.
    event = "VimEnter",
    config = function()
      require("vgit").setup()
    end,
  },
  {
    -- :Diffview
    "sindrets/diffview.nvim",
  },
}
