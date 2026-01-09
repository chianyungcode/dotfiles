return {
  -- https://github.com/rachartier/tiny-glimmer.nvim
  -- DESC: A Neovim plugin that adds smooth, customizable animations to text operations like yank, paste, search, undo/redo, and more.
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

  -- https://github.com/mluders/comfy-line-numbers.nvim
  -- DESC: change line numbers to more left-handed, example instead of 6j it will be 11j
  {
    "mluders/comfy-line-numbers.nvim",
    enabled = false,
    opts = {},
  },

  {
    -- https://github.com/Bekaboo/dropbar.nvim
    -- DESC: Breadcrumb menunjukkan file path diatas
    "Bekaboo/dropbar.nvim",
    enabled = false,
    config = function()
      require("dropbar").setup({
        icons = {
          kinds = {
            symbols = {
              Folder = " ",
            },
          },
        },
      })

      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },
  {
    -- Buffer tab line on top
    "akinsho/bufferline.nvim",
    enabled = false,
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
  },
  {
    -- Lua line in bottom
    -- https://github.com/meuter/lualine-so-fancy.nvim
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "meuter/lualine-so-fancy.nvim",
    },
    opts = {
      options = {
        -- theme = "seoul256",
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
        refresh = {
          statusline = 100,
        },
      },
      sections = {
        lualine_a = {
          { "fancy_mode", width = 3 },
        },
        lualine_b = {
          { "fancy_branch" },
          { "fancy_diff" }, -- showing the diff for text added, modified and removed
        },
        lualine_c = {
          { "filename", path = 4 }, -- path = 4 (only showing path for the filename and parent directory, not the entire path, the option is 0,1,2,3,4)
        },
        lualine_x = {
          { "fancy_macro" },
          { "fancy_diagnostics" },
          { "fancy_searchcount" },
          { "fancy_location" }, -- location of the current cursor -> $line_number | $character_position_number
        },
        lualine_y = {
          -- { "fancy_filetype", ts_icon = "" }, -- Showing filetype for the current buffer
          {},
        },
        lualine_z = {
          { "fancy_lsp_servers" },
        },
      },
    },
  },
  {
    -- Dimming window
    "tadaa/vimade",
    enabled = false,
    -- default opts (you can partially set these or configure them however you like)
    opts = {
      -- Recipe can be any of 'default', 'minimalist', 'duo', and 'ripple'
      -- Set animate = true to enable animations on any recipe.
      -- See the docs for other config options.
      recipe = { "default", { animate = true } },
      ncmode = "buffers", -- use 'windows' to fade inactive windows
      fadelevel = 0.4, -- any value between 0 and 1. 0 is hidden and 1 is opaque.
      tint = {
        -- bg = {rgb={0,0,0}, intensity=0.3}, -- adds 30% black to background
        -- fg = {rgb={0,0,255}, intensity=0.3}, -- adds 30% blue to foreground
        -- fg = {rgb={120,120,120}, intensity=1}, -- all text will be gray
        -- sp = {rgb={255,0,0}, intensity=0.5}, -- adds 50% red to special characters
        -- you can also use functions for tint or any value part in the tint object
        -- to create window-specific configurations
        -- see the `Tinting` section of the README for more details.
      },

      -- Changes the real or theoretical background color. basebg can be used to give
      -- transparent terminals accurating dimming.  See the 'Preparing a transparent terminal'
      -- section in the README.md for more info.
      -- basebg = [23,23,23],
      basebg = "",

      -- prevent a window or buffer from being styled. You
      blocklist = {
        default = {
          buf_opts = { buftype = { "prompt", "terminal" } },
          win_config = { relative = true },
          -- buf_name = {'name1','name2', name3'},
          -- buf_vars = { variable = {'match1', 'match2'} },
          -- win_opts = { option = {'match1', 'match2' } },
          -- win_vars = { variable = {'match1', 'match2'} },
        },
        -- any_rule_name1 = {
        --   buf_opts = {}
        -- },
        -- only_behind_float_windows = {
        --   buf_opts = function(win, current)
        --     if (win.win_config.relative == '')
        --       and (current and current.win_config.relative ~= '') then
        --         return false
        --     end
        --     return true
        --   end
        -- },
      },
      -- Link connects windows so that they style or unstyle together.
      -- Properties are matched against the active window. Same format as blocklist above
      link = {},
      groupdiff = true, -- links diffs so that they style together
      groupscrollbind = false, -- link scrollbound windows so that they style together.

      -- enable to bind to FocusGained and FocusLost events. This allows fading inactive
      -- tmux panes.
      enablefocusfading = false,

      -- when nohlcheck is disabled the highlight tree will always be recomputed. You may
      -- want to disable this if you have a plugin that creates dynamic highlights in
      -- inactive windows. 99% of the time you shouldn't need to change this value.
      nohlcheck = true,
    },
  },
  {
    -- Show color for hexacode in Neovim, example: #FFFFFF
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = { -- set to setup table
    },
  },
}
