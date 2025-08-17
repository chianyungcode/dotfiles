-- if true then
-- 	return {}
-- end

return {
  -- { "killitar/obscure.nvim" },
  {
    "oxfist/night-owl.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
  },

  { "yorumicolors/yorumi.nvim", enabled = false, lazy = false, priority = 1000 },
  -- { "sainnhe/sonokai", lazy = false, priority = 1000 },
  -- { "mellow-theme/mellow.nvim", lazy = false, priority = 1000 },
  -- { "Yazeed1s/minimal.nvim", lazy = false, priority = 1000 },
  -- Lazy
  -- { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  -- {
  -- 	"philosofonusus/morta.nvim",
  -- 	name = "morta",
  -- 	priority = 1000,
  -- 	lazy = false,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = true,
    priority = 1000,
    -- config = function()
    -- 	require("catppuccin").setup({
    -- 		flavour = "mocha",
    -- 		color_overrides = {
    -- 			mocha = {
    -- 				base = "#2C2C2C",
    -- 				mantle = "#2C2C2C",
    -- 				crust = "#2C2C2C",
    -- 			},
    -- 		},
    --
    -- 		transparent_background = false, -- disables setting the background color.
    -- 	})
    -- end,
  },
  { "datsfilipe/vesper.nvim" },
  -- {
  -- 	"vague2k/vague.nvim",
  -- 	config = function()
  -- 		require("vague").setup({
  -- 			-- optional configuration here
  -- 		})
  -- 	end,
  -- },
  {
    "dgox16/oldworld.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("oldworld").setup({
        variants = "default",
      })
    end,
  },
  -- {
  -- 	"ricardoraposo/nightwolf.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	opts = {
  -- 		theme = "dark-gray",
  -- 	},
  -- },
  -- {
  -- 	"rebelot/kanagawa.nvim",
  -- 	lazy = false,
  -- 	priority = 1000,
  -- 	config = function()
  -- 		require("kanagawa").setup({
  -- 			theme = "lotus",
  -- 		})
  -- 	end,
  -- },
  {
    "folke/tokyonight.nvim",
    enabled = false,
    -- opts = {
    -- 	transparent = true,
    -- 	styles = {
    -- 		sidebars = "transparent",
    -- 		floats = "transparent",
    -- 	},
    -- },
  },
  {
    "olivercederborg/poimandres.nvim",
    lazy = false,
    enabled = false,
    priority = 1000,
    config = function()
      require("poimandres").setup({
        -- leave this setup function empty for default config
        -- or refer to the configuration section
        -- for configuration options
      })
    end,
  },
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Default options:
      require("kanso").setup({
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = {},
        typeStyle = {},
        disableItalics = false,
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = { zen = {}, pearl = {}, ink = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,
        theme = "zen", -- Load "zen" theme
        background = { -- map the value of 'background' option to a theme
          dark = "zen", -- try "ink" !
          light = "pearl",
        },
      })
    end,
  },
  {
    "olimorris/onedarkpro.nvim",
    enabled = false,
    priority = 1000, -- Ensure it loads first
    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = true,
        },
      })
    end,
  },
  {
    "nickkadutskyi/jb.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    enabled = false,
  },
  {
    "Skardyy/makurai-nvim",
  },
  {
    "metalelf0/black-metal-theme-neovim",
    lazy = false,
    priority = 1000,
    -- config = function()
    -- 	require("black-metal").setup({
    -- 		-- optional configuration here
    -- 	})
    -- 	require("black-metal").load()
    -- end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
