return {
  {
    "rmagatti/auto-session",
    enabled = true, -- disable this plugin for faster startup time
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    enabled = true,
    opts = {
      -- add any custom options here
    },
  },
}
