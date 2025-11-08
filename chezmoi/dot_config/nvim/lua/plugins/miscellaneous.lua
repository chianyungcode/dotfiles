return {

  -- https://github.com/mluders/comfy-line-numbers.nvim
  -- DESC: change line numbers to more left-handed, example instead of 6j it will be 11j
  {
    "mluders/comfy-line-numbers.nvim",
    enabled = false,
    opts = {},
  },

  {
    "m4xshen/hardtime.nvim",
    enabled = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  -- https://github.com/alker0/chezmoi.vim
  -- DESC: syntax highlighting for .tmpl in chezmoi
  {
    "alker0/chezmoi.vim",
    enabled = false,
  },

  -- https://github.com/meznaric/key-analyzer.nvim
  -- DESC: Ever wondered which mappings are free to be mapped? Now it's a easier to figure it out.
  { "meznaric/key-analyzer.nvim", opts = {} },

  -- Plugin for tracking your time in Neovim
  { "wakatime/vim-wakatime", lazy = false },

  -- https://github.com/nvzone/floaterm
  -- DESC: multiple floating terminal inside neovim
  {
    "nvzone/floaterm",
    enabled = false,
    dependencies = "nvzone/volt",
    opts = {},
    keys = {
      vim.keymap.set("n", "<leader>i", ":FloatermToggle<CR>", { noremap = true, silent = true }),
    },
    cmd = "FloatermToggle",
  },

  {
    "cdmill/focus.nvim",
    enabled = false,
    cmd = { "Focus", "Zen", "Narrow" },
    opts = { -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- https://github.com/hakonharnes/img-clip.nvim
  -- DESC: Paste image to neovim in normal mode, just press cmd + v in macos or ctrl + v in linux
  {
    "HakonHarnes/img-clip.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      -- add options here
      -- or leave it empty to use the default settings
      default = {
        -- file and directory options
        -- expands dir_path to an absolute path
        -- When you paste a new image, and you hover over its path, instead of:
        -- test-images-img/2024-06-03-at-10-58-55.webp
        -- You would see the entire path:
        -- /Users/chianyung/github/obsidian_main/998-test/test-images-img/2024-06-03-at-10-58-55.webp
        --
        -- IN MY CASE I DON'T WANT TO USE ABSOLUTE PATHS
        -- if I switch to a nother computer and I have a different username,
        -- therefore a different home directory, that's a problem because the
        -- absolute paths will be pointing to a different directory
        use_absolute_path = false, ---@type boolean

        -- make dir_path relative to current file rather than the cwd
        -- To see your current working directory run `:pwd`
        -- So if this is set to false, the image will be created in that cwd
        -- In my case, I want images to be where the file is, so I set it to true
        relative_to_current_file = false, ---@type boolean

        dir_path = "_assets", ---@type string | fun(): string -- default is 'assets/' but i want use '_assets'
        -- sementara seperti ini karena untuk membuka dengan system app `gx` , path nya sepertinya bergantung pada cwd, misalnya jika path nya '../../_assets/file.png' tidak akan bisa dibuka muncul error, karena ini sepertinya mengganggap membukanya keluar dari root directory saat ini jadi naik 2 tingkat dari root directory saat ini. Padahal yang diharapkan adalah membuka directory 2 tingkah dibawahnya

        -- If you want to get prompted for the filename when pasting an image
        -- This is the actual name that the physical file will have
        -- If you set it to true, enter the name without spaces or extension `test-image-1`
        -- Remember we specified the extension above
        --
        -- I don't want to give my images a name, but instead autofill it using
        -- the date and time as shown on `file_name` below
        prompt_for_file_name = false, ---@type boolean
        file_name = "%y%m%d-%H%M%S", ---@type string

        -- -- Set the extension that the image file will have
        -- -- I'm also specifying the image options with the `process_cmd`
        -- -- Notice that I HAVE to convert the images to the desired format
        -- -- If you don't specify the output format, you won't see the size decrease
        extension = "avif", ---@type string
        process_cmd = "convert - -quality 75 avif:-", ---@type string

        filetypes = {
          markdown = {
            -- encode spaces and special characters in file path
            url_encode_path = true, ---@type boolean
          },
        },
      },
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },

  -- https://github.com/3rd/image.nvim
  -- DESC: show image in neovim
  {
    "3rd/image.nvim",
    enabled = false,
    -- opts = {
    --   hererocks = true,
    -- },
    config = function()
      require("image").setup({
        backend = "kitty",
        kitty_method = "normal",
        integrations = {
          markdown = {
            only_render_image_at_cursor = true,
            only_render_image_at_cursor_mode = "popup",
            floating_windows = true,
          },
        },
      })
    end,
  },

  -- https://github.com/OXY2DEV/helpview.nvimj
  -- DESC: A hackable & fancy vimdoc viewer for Neovim
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
  },

  -- https://github.com/ray-x/go.nvim
  -- DESC: A modern go neovim plugin based on treesitter, nvim-lsp and dap debugger.
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

  -- https://github.com/folke/noice.nvim
  -- DESC: an ui for notification in neovim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        -- This is the search bar or popup that shows up when you press /
        -- Setting this to false makes it a popup and true the search bar at the bottom
        -- search middle
        bottom_search = false,
      },
      messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = "mini", -- default view for messages
        view_error = "mini", -- view for errors
        view_warn = "mini", -- view for warnings
        view_history = "mini", -- view for :messages
        view_search = "mini", -- view for search count messages. Set to `false` to disable
      },
      notify = {
        -- Noice can be used as `vim.notify` so you can route any notification like other messages
        -- Notification messages have their level and other properties set.
        -- event is always "notify" and kind can be any log level as a string
        -- The default routes will forward notifications to nvim-notify
        -- Benefit of using Noice for this is the routing and consistent history view
        enabled = true,
        view = "mini",
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

  -- https://github.com/nvzone/showkeys
  -- DESC: Eye-candy keys screencaster for Neovim
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>O", group = "Ecolog" },
          { "<leader>o", group = "Opencode and Outline" },
          { "<leader>h", group = "Gitsigns" },
        },
      },
    },
  },

  -- https://github.com/ph1losof/ecolog.nvim
  -- DESC: Your environment guardian in Neovim.
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

  {
    "rachartier/tiny-glimmer.nvim",
    enabled = false,
    -- dependencies = { "gbprod/yanky.nvim" },
    event = "VeryLazy",
    priority = 10, -- Low priority to catch other plugins' keybindings
    keys = {
      "n",
      "N",
    },
    config = function()
      require("tiny-glimmer").setup({
        overwrite = {
          search = {
            enabled = true,
          },
          undo = {
            enabled = true,
          },
          redo = {
            enabled = true,
          },
        },
      })
    end,
  },
}
