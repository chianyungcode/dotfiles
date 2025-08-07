return {
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
      create_new = false,
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

    templates = {
      folder = "_templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },

    ui = {
      enable = false, -- Need to disable because using render-markdown.nvim plugin
    },
  },
}
