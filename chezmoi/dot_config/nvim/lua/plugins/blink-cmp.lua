-- https://cmp.saghen.dev/

return {
  -- https://github.com/saghen/blink.indent
  -- DESC: indent guide for neovim, alternative to snacks.indent
  {
    "saghen/blink.indent",
    enabled = false,
    --- @module 'blink.indent'
    --- @type blink.indent.Config
    opts = {
      static = {
        char = "┃",
      },
      scope = {
        char = "┃",
      },
    },
  },

  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
      -- { "saghen/blink.compat", version = false }, -- NOTE: this is for obsidian.nvim, back before when it not supported blink.cmp, so it uses blink.compat to make it sources from nvim.cmp
      {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      },
      { "xieyonn/blink-cmp-dat-word" },
    },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      cmdline = {
        enabled = true,
        keymap = { preset = "inherit" },
        completion = { menu = { auto_show = true }, ghost_text = { enabled = true } },
      },
      -- snippets = { preset = "luasnip" },
      sources = {
        -- NOTE: this is for obsidian.nvim, back before when it not supported blink.cmp, so it uses blink.compat to make it sources from nvim.cmp
        -- compat = { "obsidian", "obsidian_new", "obsidian_tags" },
        -- default = { "obsidian", "obsidian_new", "obsidian_tags" },

        default = { "ecolog", "dadbod", "lsp", "path", "snippets", "buffer", "datword" },
        per_filetype = {
          sql = { "snippets", "dadbod", "lsp", "buffer" },
        },
        providers = {
          snippets = {
            min_keyword_length = 1,
            score_offset = 4,
          },
          lsp = {
            min_keyword_length = 1,
            score_offset = 3,
          },
          path = {
            min_keyword_length = 2,
            score_offset = 2,
          },
          buffer = {
            min_keyword_length = 2,
            score_offset = 1,
          },
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
            score_offset = 50,
            min_keyword_length = 1,
          }, -- make score_offset bigger for prioritize dadbod completion over other completion
          ecolog = { name = "ecolog", module = "ecolog.integrations.cmp.blink_cmp" },
          datword = {
            name = "DatWord",
            min_keyword_length = 3,
            score_offset = 1,
            module = "blink-cmp-dat-word",
            opts = {
              paths = {
                -- "path_to_your_words.txt", -- add your owned word files before dictionary.
                "~/.local/share/chezmoi/others/dictionary/combined_root_words.txt",
                "~/.local/share/chezmoi/others/dictionary/combined_slang_words.txt",
                "~/.local/share/chezmoi/others/dictionary/combined_stop_words.txt",
                -- "/usr/share/dict/words", -- This file is included by default on Linux/macOS.
              },
            },

            -- NOTE: this is for obsidian.nvim, back before when it not supported blink.cmp, so it uses blink.compat to make it sources from nvim.cmp
            -- 	obsidian = {
            -- 		name = "obsidian",
            -- 		module = "blink.compat.source",
            -- 	},
            -- 	obsidian_new = {
            -- 		name = "obsidian_new",
            -- 		module = "blink.compat.source",
            -- 	},
            -- 	obsidian_tags = {
            -- 		name = "obsidian_tags",
            -- 		module = "blink.compat.source",
            -- 	},
          },
        },
      },

      keymap = {
        preset = "default", -- Opsi ini bisa dilihat disini https://github.com/Saghen/blink.cmp?tab=readme-ov-file#configuration khususnya bagian default-configuration toggle
        -- ["<Tab>"] = {
        --   "snippet_forward",
        --   function() -- sidekick next edit suggestion
        --     return require("sidekick").nes_jump_or_apply()
        --   end,
        --   function() -- if you are using Neovim's native inline completions
        --     return vim.lsp.inline_completion.get()
        --   end,
        --   "fallback",
        -- },
        ["<A-1>"] = {
          function(cmp)
            cmp.accept({ index = 1 })
          end,
        },
        ["<A-2>"] = {
          function(cmp)
            cmp.accept({ index = 2 })
          end,
        },
        ["<A-3>"] = {
          function(cmp)
            cmp.accept({ index = 3 })
          end,
        },
        ["<A-4>"] = {
          function(cmp)
            cmp.accept({ index = 4 })
          end,
        },
        ["<A-5>"] = {
          function(cmp)
            cmp.accept({ index = 5 })
          end,
        },
        ["<A-6>"] = {
          function(cmp)
            cmp.accept({ index = 6 })
          end,
        },
        ["<A-7>"] = {
          function(cmp)
            cmp.accept({ index = 7 })
          end,
        },
        ["<A-8>"] = {
          function(cmp)
            cmp.accept({ index = 8 })
          end,
        },
        ["<A-9>"] = {
          function(cmp)
            cmp.accept({ index = 9 })
          end,
        },
      },

      -- completion = {
      --   documentation = {
      --     window = {
      --       border = "single",
      --     },
      --   },
      --   menu = {
      --     border = "single",
      --     scrollbar = false,
      --     draw = {
      --       columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
      --       components = {
      --         item_idx = {
      --           text = function(ctx)
      --             return tostring(ctx.idx)
      --           end,
      --           highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
      --           width = { fill = false },
      --         },
      --         -- label = { width = { fill = false } }, -- default is true
      --         label_description = { width = { fill = true } },
      --         -- kind_icon = { width = { fill = false } },
      --       },
      --     },
      --   },
      -- },

      completion = {
        documentation = {
          window = {
            border = {
              { "╭", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╮", "FloatBorder" },
              { "│", "FloatBorder" },
              { "╯", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╰", "FloatBorder" },
              { "│", "FloatBorder" },
            },
          },
        },
        menu = {
          scrollbar = false,
          border = {
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
          },
          draw = {
            columns = { { "item_idx" }, { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            -- columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
            -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
            components = {
              item_idx = {
                text = function(ctx)
                  return tostring(ctx.idx)
                end,
                highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
                width = { fill = false },
              },
              label = { width = { fill = false } }, -- default is true
              label_description = { width = { fill = true } },
              kind_icon = { width = { fill = false } },
            },
          },
        },
      },
    },
  },
}
