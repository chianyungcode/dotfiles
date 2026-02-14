-- if true then
-- 	return {}
-- end

return {
  -- { "killitar/obscure.nvim" },

  -- https://github.com/uhs-robert/oasis.nvim
  {
    "uhs-robert/oasis.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
  },

  {
    "oxfist/night-owl.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    -- opts = {
    --   transparent_background = true,
    -- },
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
    lazy = false,
    enabled = false,
    priority = 1000,
    -- https://github.com/LazyVim/LazyVim/issues/6355#issuecomment-3212986215
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base = "#161617",
            mantle = "#161617",
            crust = "#161617",
          },
        },
        transparent_background = false, -- disables setting the background color.
      })
    end,
  },

  {
    "abhilash26/mapledark.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
  },

  { "datsfilipe/vesper.nvim", enabled = false },
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
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("oldworld").setup({
        variants = "default",
        -- highlight_overrides = {
        --   Normal = { bg = "NONE" },
        --   NormalNC = { bg = "NONE" },
        --   CursorLine = { bg = "NONE" },
        -- },
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
  {
    "rebelot/kanagawa.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    -- config = function()
    --   require("kanagawa").setup({
    --     theme = "dragon",
    --   })
    -- end,
  },
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
    enabled = false,
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
    "rose-pine/neovim",
    name = "rose-pine",
    enabled = false,
  },

  {
    "Skardyy/makurai-nvim",
    enabled = false,
  },

  {
    "metalelf0/black-metal-theme-neovim",
    enabled = false,
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
    "tiagovla/tokyodark.nvim",
    enabled = false,
  },
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },

  {
    "metalelf0/jellybeans-nvim",
    enabled = false,
    dependencies = { "rktjmp/lush.nvim" },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "oldworld",
    },
  },
}
