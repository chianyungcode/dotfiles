return {
  {
    "lewis6991/gitsigns.nvim",
    -- config = function()
    -- 	require("gitsigns").setup({
    -- 		current_line_blame_opts = {
    -- 			virt_text = true,
    -- 			virt_text_priority = 100,
    -- 		},
    -- 	})
    -- end,
  },
  {
    "tanvirtin/vgit.nvim",
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
