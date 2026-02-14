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

local function running_note_id(...)
  -- Always name distraction sheets after the current date.
  local today = os.date("%Y-%m-%d")
  return string.format("Running Note - %s", today)
end

return {
  -- https://github.com/OXY2DEV/markview.nvim
  -- DESC: fancy visual markdown in neovim
  {
    -- For `plugins.lua` users.
    "OXY2DEV/markview.nvim",
    enabled = false,
    lazy = false,

    -- Completion for `blink.cmp`
    dependencies = { "saghen/blink.cmp" },
  },
  -- https://github.com/apdot/doodle
  -- DESC: obsidian similar
  {
    "apdot/doodle",
    enabled = false,
  },

  -- https://github.com/obsidian-nvim/obsidian.nvim
  -- default config: https://github.com/obsidian-nvim/obsidian.nvim/blob/main/lua/obsidian/config/default.lua
  -- DESC: obsidian in neovim
  {
    "obsidian-nvim/obsidian.nvim",
    enabled = false,
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
      checkbox = {
        order = { "x", " " },
      },
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
      notes_subdir = "000 - Objects/000 - Zettels",

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
            notes_subdir = "000 - Objects/090 - Learn/020-learn-notes",
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
          weblinks = {
            notes_subdir = "000 - Objects/020 - Weblinks",
            note_id_func = default_note_id,
          },
          running_note = {
            notes_subdir = "000 - Objects/030 - Running Notes",
            note_id_func = running_note_id,
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

  -- https://github.com/zion-off/mole.nvim
  -- DESC: annotation for personal docs, like running note
  {
    "zion-off/mole.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },

  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- DESC: fancy visual markdown in neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = true,
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
