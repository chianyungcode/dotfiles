return {
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
    "echasnovski/mini.files",
    enabled = true,
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
      })
    end,
  },
  {
    -- youtube videos: https://www.youtube.com/watch?v=p_sVgHS2zcA
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = true, -- Set to 'true' if want a labels when searching with '/' or '?'
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
  {
    "chentoast/marks.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {},
  },
}
