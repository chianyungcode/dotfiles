local function default_note_id(...)
  return require("obsidian.builtin").zettel_id(...)
end

-- Use the provided title for the note id when possible, falling back to the default generator.
local function title_note_id(title, ...)
  if title and title ~= "" then
    -- Trim whitespace and guard against accidental path separators.
    local normalized = title:gsub("^%s+", ""):gsub("%s+$", "")
    normalized = normalized:gsub("[/\\]", "-")
    if normalized ~= "" then
      return normalized
    end
  end

  return default_note_id(title, ...)
end

local function distraction_sheet_note_id(...)
  -- Always name distraction sheets after the current date.
  local today = os.date("%Y-%m-%d")
  return string.format("Distraction Sheet - %s", today)
end

return {
  -- https://github.com/apdot/doodle
  -- DESC: obsidian similar
  {
    "apdot/doodle",
    enabled = false,
  },

  -- https://github.com/obsidian-nvim/obsidian.nvim
  -- DESC: obsidian in neovim
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/vault-obsidian/",
        },
        {
          name = "work",
          path = "~/Documents/obsidian-vaults/work",
        },
      },

      -- Alternatively - and for backwards compatibility - you can set 'dir' to a single path instead of
      -- 'workspaces'. For example:
      -- dir = "~/vaults/work",

      -- Optional, if you keep notes in a specific subdirectory of your vault.
      notes_subdir = "notes",

      -- Where to put new notes. Valid options are
      -- _ "current_dir" - put new notes in same directory as the current buffer.
      -- _ "notes_subdir" - put new notes in the default notes subdirectory.
      new_notes_location = "notes_subdir",

      completion = {
        nvim_cmp = false,
        -- Enables completion using blink.cmp
        blink = true,
        -- Trigger completion at 2 chars.
        min_chars = 2,
        -- Set to false to disable new note creation in the picker
        create_new = true,
      },

      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
      name = "snacks.pick",
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      -- snacks.pick doesnt support this
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },

      daily_notes = {
        -- Optional, if you keep daily notes in a separate directory.
        folder = "notes/dailies",
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = "%Y-%m-%d",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%B %-d, %Y",
        -- Optional, default tags to add to each new daily note created.
        default_tags = { "daily-notes" },
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = nil,
        -- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
        workdays_only = true,
      },

      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "wiki",

      -- references: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template
      templates = {
        customizations = {
          learn_notes = {
            notes_subdir = "Learn/10-rough-notes",
            note_id_func = default_note_id,
          },
          quote = {
            notes_subdir = "notes/quotes",
            note_id_func = default_note_id,
          },
          people = {
            notes_subdir = "000 - Objects/010 - People",
            note_id_func = title_note_id,
          },
          distraction_sheet = {
            notes_subdir = "005 - Brain Dump/010 - Distraction Sheet",
            note_id_func = distraction_sheet_note_id,
          },
        },
        folder = "_templates/from_neovim",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },

      ui = {
        enable = false, -- Need to disable because using render-markdown.nvim plugin
      },
    },

    -- config = function(_, opts)
    --   require("obsidian").setup(opts)
    --
    --   local map = vim.keymap.set
    --   local opts = { noremap = true, silent = true }
    --
    --   map("n", "<leader>yn", "<cmd>ObsidianNew<CR>", { desc = "New note" })
    --   map("n", "<leader>ym", "<cmd>ObsidianToday<CR>", { desc = "Today" })
    --   map("n", "<leader>yy", "<cmd>ObsidianYesterday<CR>", { desc = "Yesterday" })
    --   map("n", "<leader>yu", "<cmd>ObsidianTomorrow<CR>", { desc = "Tomorrow" })
    --   map("n", "<leader>y.", "<cmd>ObsidianDailies<CR>", { desc = "List daily notes" })
    --   map("n", "<leader>yi", "<cmd>ObsidianPasteImg<CR>", { desc = "Paste image" })
    --   map("n", "<leader>yl", "<cmd>ObsidianLinks<CR>", { desc = "All links in note" })
    --   map("n", "<leader>yr", "<cmd>ObsidianRename<CR>", { desc = "Rename note" })
    --   map("n", "<leader>yb", "<cmd>ObsidianBacklinks<CR>", { desc = "Backlinks" })
    --   map("n", "<leader>yk", "<cmd>ObsidianTOC<CR>", { desc = "Table of Contents" })
    --   map("n", "<leader>ys", "<cmd>ObsidianSearch<CR>", { desc = "Search notes" })
    --   map("n", "<leader>yw", "<cmd>ObsidianWorkspace<CR>", { desc = "Switch workspace" })
    --   map("n", "<leader>yq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick switch note" })
    --   map("n", "<leader>yt", "<cmd>ObsidianTemplate<CR>", { desc = "Insert template" })
    --   map("n", "<leader>yv", "<cmd>ObsidianFollowLink vsplit<CR>", { desc = "Follow link (vsplit)" })
    --   map("n", "<leader>yh", "<cmd>ObsidianFollowLink hsplit<CR>", { desc = "Follow link (hsplit)" })
    --   map("v", "<leader>yx", "<cmd>ObsidianExtractNote<CR>", { desc = "Extract to new note" })
    --   map("n", "<leader>yj", "<cmd>ObsidianToggleCheckbox<CR>", { desc = "Toggle checkbox" })
    --   map("v", "<leader>y,", "<cmd>ObsidianLink<CR>", { desc = "Link to existing note" })
    --   map("v", "<leader>y/", "<cmd>ObsidianLinkNew<CR>", { desc = "Link to new note" })
    --   map("n", "<leader>yo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian app" })
    --   map("n", "<leader>yg", "<cmd>ObsidianTags<CR>", { desc = "List tags" })
    --   map("n", "<leader>yf", "<cmd>ObsidianFollowLink<CR>", { desc = "Follow link" })
    --   map("n", "<leader>yz", "<cmd>ObsidianNewFromTemplate<CR>", { desc = "New from template" })
    -- end,
  },

  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- DESC: fancy visual markdown in neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      require("render-markdown").setup({
        latex = {
          enabled = false,
        },
        heading = {
          enabled = true,
          sign = true,
          position = "overlay",
          icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
          signs = { "󰫎 " },
          width = "full",
          left_margin = 0,
          left_pad = 0,
          right_pad = 0,
          min_width = 0,
          border = false,
          border_virtual = false,
          border_prefix = false,
          above = "▄",
          below = "▀",
          backgrounds = {
            "RenderMarkdownH1Bg",
            "RenderMarkdownH2Bg",
            "RenderMarkdownH3Bg",
            "RenderMarkdownH4Bg",
            "RenderMarkdownH5Bg",
            "RenderMarkdownH6Bg",
          },
          foregrounds = {
            "RenderMarkdownH1",
            "RenderMarkdownH2",
            "RenderMarkdownH3",
            "RenderMarkdownH4",
            "RenderMarkdownH5",
            "RenderMarkdownH6",
          },
        },
        pipe_table = {
          enabled = true,
          preset = "none",
          style = "full",
          cell = "padded",
          padding = 1,
          min_width = 0,
          border = {
            "┌",
            "┬",
            "┐",
            "├",
            "┼",
            "┤",
            "└",
            "┴",
            "┘",
            "│",
            "─",
          },
          alignment_indicator = "━",
          head = "RenderMarkdownTableHead",
          row = "RenderMarkdownTableRow",
          filler = "RenderMarkdownTableFill",
        },
      })
    end,
  },

  {
    "brianhuster/live-preview.nvim",
    enabled = false,
    dependencies = {
      -- You can choose one of the following pickers
      "folke/snacks.nvim",
    },
  },

  -- Bullets.vim is a Vim/NeoVim plugin for automated bullet lists.
  -- https://github.com/bullets-vim/bullets.vim
  {
    "bullets-vim/bullets.vim",
  },
}
