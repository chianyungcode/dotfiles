return {
  -- https://github.com/dmtrKovalenko/fff.nvim
  -- DESC: File picker, alternative to snacks.picker, telescope, mini.picker and etc.
  {
    "dmtrKovalenko/fff.nvim",
    enabled = false,
    build = function()
      -- this will download prebuild binary or try to use existing rustup toolchain to build from source
      -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
      require("fff.download").download_or_build_binary()
    end,
    -- if you are using nixos
    -- build = "nix run .#release",
    opts = { -- (optional)
      debug = {
        enabled = true, -- we expect your collaboration at least during the beta
        show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
      },
    },
    -- No need to lazy-load with lazy.nvim.
    -- This plugin initializes itself lazily.
    lazy = false,
    keys = {
      {
        "ff", -- try it if you didn't it is a banger keybinding for a picker
        function()
          require("fff").find_files()
        end,
        desc = "FFFind files",
      },
    },
  },
  {
    "mikavilpas/yazi.nvim",
    enabled = false,
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig | {}
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    -- 👇 if you use `open_for_directories=true`, this is recommended
    init = function()
      -- mark netrw as loaded so it's not loaded at all.
      --
      -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  -- https://github.com/chentoast/marks.nvim
  -- DESC: A better user experience for interacting with and manipulating Vim marks.
  {
    "chentoast/marks.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    enabled = false,
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]], -- default key untuk toggle
        direction = "float",
      })
    end,
  },

  -- https://github.com/A7Lavinraj/fyler.nvim
  -- DESC: Combination of nvim-tree and oil.nvim, file explorer with tree view and vim operations
  {
    "A7Lavinraj/fyler.nvim",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>fm",
        function()
          require("fyler").open({
            kind = "float",
          })
        end,
        desc = "Open Fyler",
      },
    },
    opts = {
      views = {
        finder = {
          icon = {
            directory_collapsed = " ",
            directory_expanded = " ",
          },
          win = {
            win_opts = {
              number = true,
              relativenumber = true,
            },
          },
        },
      },
    },
  },

  {
    "leath-dub/snipe.nvim",
    enabled = true,
    keys = {
      {
        "gb",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    --- @type snipe.DefaultConfig
    opts = {
      ui = {
        position = "center",
        open_win_override = {
          border = "rounded",
        },
        text_align = "file-first",
      },
      hints = {
        dictionary = "asdflewcmpghio",
      },
    },
  },

  {
    -- Ini hanya untuk tambahan custom options saja, untuk defaultnya diinstall via LazyExtras di file lazy.lua
    -- NOTE: Install mini.files with LazyExtras, because it preconfigured open mini.files where's directories in the current buffer and showing the preview
    "nvim-mini/mini.files",
    enabled = false,
    version = false,
    opts = {
      -- No need to copy this inside `setup()`. Will be used automatically.

      -- Customization of shown content
      content = {
        -- Predicate for which file system entries to show
        filter = nil,
        -- What prefix to show to the left of file system entry
        prefix = nil,
        -- In which order to show file system entries
        sort = nil,
      },

      -- Module mappings created only inside explorer.
      -- Use `''` (empty string) to not create one.
      mappings = {
        close = "q",
        go_in = "l",
        go_in_plus = "L",
        go_out = "h",
        go_out_plus = "H",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },

      -- General options
      options = {
        -- Whether to delete permanently or move into module-specific trash
        permanent_delete = true,
        -- Whether to use for editing directories
        use_as_default_explorer = true,
      },

      -- Customization of explorer windows
      windows = {
        -- Maximum number of windows to show side by side
        max_number = math.huge,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 25,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 75,
      },
    },
  },

  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>ol", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

      require("outline").setup({
        -- Your setup opts here (leave empty to use defaults)
        outline_window = {
          width = 35,
          auto_jump = true,

          show_numbers = true,
          show_relative_numbers = true,
        },
      })
    end,
  },

  -- https://github.com/FluxxField/smart-motion.nvim
  -- DESC: alternative to flash, leap, hop nvim
  {
    "FluxxField/smart-motion.nvim",
    enabled = false,
    opts = {
      presets = {
        words = true, -- w, b, e, ge
        lines = true, -- j, k
        search = true, -- s, f, F, t, T, ;, ,, gs
        delete = true, -- d, dt, dT, rdw, rdl
        yank = true, -- y, yt, yT, ryw, ryl
        change = true, -- c, ct, cT
        paste = true, -- p, P
        treesitter = true, -- ]], [[, ]c, [c, ]b, [b, daa, caa, yaa, dfn, cfn, yfn, saa
        diagnostics = true, -- ]d, [d, ]e, [e
        git = true, -- ]g, [g
        quickfix = true, -- ]q, [q, ]l, [l
        marks = true, -- g', gm
        misc = true, -- . (repeat), gmd, gmy
      },
    },
  },

  {
    -- youtube videos: https://www.youtube.com/watch?v=p_sVgHS2zcA
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = false, -- Set to 'true' if want a labels when searching with '/' or '?'
        },
        char = {
          jump_labels = true,
        },
      },
      search = {
        multi_window = false,
      },
    },
    -- stylua: ignore
  },

  {
    "smoka7/multicursors.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },
}
