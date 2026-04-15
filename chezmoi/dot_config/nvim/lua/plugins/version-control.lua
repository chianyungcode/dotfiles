return {
  --
  --
  --
  {
    "mrdwarf7/lazyjui.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        -- Default is <Leader>jj
        -- An example of a custom mapping to open the interface
        "<Leader>gj",
        function()
          require("lazyjui").open()
        end,
      },
    },
    -- You can also simply pass `opts = true` or `opts = {}` and the default options will be used
    ---@type lazyjui.Opts
    opts = {
      -- Optionally (default):
      border = {
        chars = { "", "", "", "", "", "", "", "" }, -- either set all to empty to remove the entire outer border (or nil/{})
        -- Use custom set of border chars (must be 8 long)
        -- border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
        thickness = 0, -- This handles the border of the 'outer' window it's nested inside, generally this is invisible
        -- See `:h nvim_win_set_hl_ns()` and associated docs for more details
        -- previous option was: "FloatBorder:LazyJuiBorder,NormalFloat:LazyJuiFloat", -- up to you how to set
        winhl_str = "",
      },

      -- The below options will now produce a warning advising to use the above syntax instead.
      -- they'll work for a while; but note that the internal mapping will be removed in the future.
      ---@deprecated use 'opts.border.chars' instead
      -- border_chars = {},
      ---@deprecated use 'opts.border.thickness' instead
      -- border_thickness = 0,
      ---@deprecated use 'opts.border.winhl_str' instead
      -- border_winhl_str = "FloatBorder:LazyJuiBorder,NormalFloat:LazyJuiFloat",

      -- Support for custom command pass-through
      -- In this example, we use the revset `all()` command
      --
      -- Will default to just `jjui`
      cmd = { "jjui" },
      height = 0.8, -- default is 0.8,
      width = 0.9, -- default is 0.9,
      winblend = 0, -- default is 0 (fully opaque). Set to 100 for fully transparent (not recommended though).
      -- hide_only = false, -- This is **experimental** and is subject to changing, currently not available
      use_default_keymaps = true, -- setting this to false will result in no default mappings at all
    },
  },

  { "yannvanhalewyn/jujutsu.nvim", enabled = false },
  -- https://github.com/NicolasGB/jj.nvim
  -- DESC: jj vcs integration with neovim
  {
    "nicolasgb/jj.nvim",
    enabled = false,
    config = function()
      require("jj").setup({})
    end,
  },

  -- https://github.com/oribarilan/lensline.nvim
  -- DESC: A lightweight Neovim plugin that displays customizable, contextual information directly above (or beside) functions, like references and authorship.
  {
    "oribarilan/lensline.nvim",
    enabled = false,
    tag = "1.0.0", -- or: branch = 'release/1.x' for latest non-breaking updates
    event = "LspAttach",
    config = function()
      require("lensline").setup()
    end,
  },

  -- https://github.com/lewis6991/gitsigns.nvim
  -- DESC: Deep buffer integration for Git
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
        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end, {
            desc = "Navigate to next hunk - moves to next diff change in diff mode or next Git hunk otherwise",
          })

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end, {
            desc = "Navigate to previous hunk - moves to previous diff change in diff mode or previous Git hunk otherwise",
          })

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk, {
            desc = "Stage current hunk", -- Stage the currently active hunk for commit
          })
          map("n", "<leader>hr", gitsigns.reset_hunk, {
            desc = "Reset current hunk", -- Revert changes in the currently active hunk
          })

          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, {
            desc = "Stage selected hunks", -- Stage hunks selected in visual mode for commit
          })

          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, {
            desc = "Reset selected hunks", -- Revert changes in hunks selected in visual mode
          })

          map("n", "<leader>hS", gitsigns.stage_buffer, {
            desc = "Stage entire buffer", -- Stage all changes in the current buffer/file for commit
          })
          map("n", "<leader>hR", gitsigns.reset_buffer, {
            desc = "Reset entire buffer", -- Revert all changes in the current buffer/file
          })
          map("n", "<leader>hp", gitsigns.preview_hunk, {
            desc = "Preview current hunk", -- Show a preview of the changes in the current hunk
          })
          map("n", "<leader>hi", gitsigns.preview_hunk_inline, {
            desc = "Preview current hunk inline", -- Show inline preview of the current hunk changes on the current line
          })

          map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
          end, {
            desc = "Show full git blame for current line", -- Display full git blame info for the current line
          })

          map("n", "<leader>hd", gitsigns.diffthis, {
            desc = "Show diff of current buffer", -- Show the diff of the current file against HEAD
          })

          map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
          end, {
            desc = "Show diff of current buffer against previous commit", -- Show the diff of the current file against the previous commit
          })

          map("n", "<leader>hQ", function()
            gitsigns.setqflist("all")
          end, {
            desc = "Set quickfix list with all hunks", -- Populate the quickfix list with all hunks
          })
          map("n", "<leader>hq", gitsigns.setqflist, {
            desc = "Set quickfix list with hunks", -- Populate the quickfix list with selected hunks
          })

          -- Toggles
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame, {
            desc = "Toggle current line blame", -- Toggle the git blame display for the current line
          })
          map("n", "<leader>tw", gitsigns.toggle_word_diff, {
            desc = "Toggle word diff", -- Toggle the word-level diff display
          })

          -- Text object
          map({ "o", "x" }, "ih", gitsigns.select_hunk, {
            desc = "Select current hunk", -- Select the current hunk as a text object for visual or operator mode
          })
        end,
      })
    end,
  },

  -- https://github.com/tanvirtin/vgit.nvim
  -- DESC: VGit's feature views are designed to be lightning-fast. Whether you're diving into a file's history, comparing changes, or managing stashes.
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

  -- {
  --   "sindrets/diffview.nvim",
  -- },

  -- https://github.com/dlyongemallo
  -- DESC: fork of "sindrets/diffview.nvim", because it's not maintaned since 2024
  {
    "dlyongemallo/diffview.nvim",
    enabled = false,
    version = "*",
    -- optional: lazy-load on command
    -- cmd = {
    --     "DiffviewOpen",
    --     "DiffviewToggle",
    --     "DiffviewFileHistory",
    --     "DiffviewDiffFiles",
    --     "DiffviewLog",
    -- },
  },

  {
    "esmuellert/codediff.nvim",
    enabled = true,
    cmd = "CodeDiff",
  },

  {
    "clabby/difftastic.nvim",
    enabled = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("difftastic-nvim").setup({
        download = true, -- Auto-download pre-built binary
      })
    end,
  },
}
