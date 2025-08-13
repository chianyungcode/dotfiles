return {
  {
    -- Syntax highlighting for .tmpl in chezmoi
    "alker0/chezmoi.vim",
    enabled = false,
  },
  { "meznaric/key-analyzer.nvim", opts = {} },
  -- Plugin for tracking your time in Neovim
  { "wakatime/vim-wakatime", lazy = false },
  {
    "nvzone/floaterm",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = "FloatermToggle",
  },
  {
    "cdmill/focus.nvim",
    cmd = { "Focus", "Zen", "Narrow" },
    opts = { -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {
      -- add options here
      -- or leave it empty to use the default settings
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "3rd/image.nvim",
    opts = {
      hererocks = true,
    },
  },
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    enabled = false,
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        bottom_search = false,
      },
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
  },

  {
    "you-n-g/navigate-note.nvim",
    enabled = false,
    config = true,
    opts = {
      link_surround = {
        left = "{{",
        right = "}}",
      },
    },
  },
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
  },
  {
    -- Neovim plugin to quickly insert log statements and capture log output
    "Goose97/timber.nvim",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("timber").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>O", group = "Ecolog" },
        },
      },
    },
  },
  {
    "t3ntxcl3s/ecolog.nvim",
    -- Optional: you can add some keybindings
    -- (I personally use lspsaga so check out lspsaga integration or lsp integration for a smoother experience without separate keybindings)
    keys = {
      { "<leader>ge", "<cmd>EcologGoto<cr>", desc = "Go to env file" },
      { "<leader>Op", "<cmd>EcologPeek<cr>", desc = "Ecolog peek variable" },
      { "<leader>Os", "<cmd>EcologSelect<cr>", desc = "Switch env file" },
      { "<leader>Oh", "<cmd>EcologShelterToggle<cr>", desc = "Toggle masking / shelter to *" },
      { "<leader>OP", "<cmd>EcologShelterLinePeek<cr>", desc = "Toggle shelter line peek" },
    },
    -- Lazy loading is done internally
    lazy = false,
    opts = {
      integrations = {
        nvim_cmp = false,
        blink_cmp = true,
      },
      -- Enables shelter mode for sensitive values
      shelter = {
        configuration = {
          -- Partial mode configuration:
          -- false: completely mask values (default)
          -- true: use default partial masking settings
          -- table: customize partial masking
          -- partial_mode = false,
          -- or with custom settings:
          partial_mode = {
            show_start = 3, -- Show first 3 characters
            show_end = 3, -- Show last 3 characters
            min_mask = 3, -- Minimum masked characters
          },
          mask_char = "*", -- Character used for masking
          mask_length = nil, -- Optional: fixed length for masked portion (defaults to value length)
          skip_comments = false, -- Skip masking comment lines in environment files (default: false)
        },
        modules = {
          cmp = true, -- Enabled to mask values in completion
          peek = false, -- Enable to mask values in peek view
          files = true, -- Enabled to mask values in file buffers
          telescope = false, -- Enable to mask values in telescope integration
          telescope_previewer = false, -- Enable to mask values in telescope preview buffers
          fzf = false, -- Enable to mask values in fzf picker
          fzf_previewer = false, -- Enable to mask values in fzf preview buffers
          snacks_previewer = false, -- Enable to mask values in snacks previewer
          snacks = false, -- Enable to mask values in snacks picker
        },
      },
      -- true by default, enables built-in types (database_url, url, etc.)
      types = true,
      path = vim.fn.getcwd(), -- Path to search for .env files
      -- preferred_environment ini untuk completion di blink_cmp yang munculnya apa
      preferred_environment = "local", -- Optional: prioritize specific env files
      -- Controls how environment variables are extracted from code and how cmp works
      provider_patterns = true, -- true by default, when false will not check provider patterns
    },
  },
}
