-- if true then
-- 	return {}
-- end

return {
	{
		"saghen/blink.cmp",
		dependencies = { "saghen/blink.compat", version = false },

		opts = {
			sources = {
				compat = { "obsidian", "obsidian_new", "obsidian_tags" },

				-- Uncomment dibawah jika ingin kembali ke setinggan sebelumnya
				-- default = { "obsidian", "obsidian_new", "obsidian_tags" },
				-- providers = {
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
				-- },
			},

			-- Ini untuk ignore type file tertentu
			-- enabled = function()
			-- 	return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype)
			-- 		and vim.bo.buftype ~= "prompt"
			-- 		and vim.b.completion ~= false
			-- end,

			-- This keymap is for auto select for completion. For example <A-1> (opt + 1) will select first completion
			-- For reference check this https://github.com/Saghen/blink.cmp?tab=readme-ov-file#select-nth-item-from-the-list
			-- 2 line diatas saya adalah tulisan sendiri
			keymap = {
				preset = "default", -- Opsi ini bisa dilihat disini https://github.com/Saghen/blink.cmp?tab=readme-ov-file#configuration khususnya bagian default-configuration toggle
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

			completion = {
				documentation = {
					window = {
						border = "single",
					},
				},
				menu = {
					border = "single",
					scrollbar = false,
					draw = {
						columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
						components = {
							item_idx = {
								text = function(ctx)
									return tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
								width = { fill = false },
							},
							-- label = { width = { fill = false } }, -- default is true
							label_description = { width = { fill = true } },
							-- kind_icon = { width = { fill = false } },
						},
					},
				},
			},

			-- completion = {
			-- 	documentation = {
			-- 		window = {
			-- 			border = {
			-- 				{ "╭", "FloatBorder" },
			-- 				{ "─", "FloatBorder" },
			-- 				{ "╮", "FloatBorder" },
			-- 				{ "│", "FloatBorder" },
			-- 				{ "╯", "FloatBorder" },
			-- 				{ "─", "FloatBorder" },
			-- 				{ "╰", "FloatBorder" },
			-- 				{ "│", "FloatBorder" },
			-- 			},
			-- 		},
			-- 	},
			-- menu = {
			-- 	scrollbar = false,
			-- 	border = {
			-- 		{ "╭", "FloatBorder" },
			-- 		{ "─", "FloatBorder" },
			-- 		{ "╮", "FloatBorder" },
			-- 		{ "│", "FloatBorder" },
			-- 		{ "╯", "FloatBorder" },
			-- 		{ "─", "FloatBorder" },
			-- 		{ "╰", "FloatBorder" },
			-- 		{ "│", "FloatBorder" },
			-- 	},
			-- 	draw = {
			-- 		-- columns = { { "item_idx" }, { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			-- 		columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
			-- 		-- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			-- 		components = {
			-- 			item_idx = {
			-- 				text = function(ctx)
			-- 					return tostring(ctx.idx)
			-- 				end,
			-- 				highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
			-- 				width = { fill = false },
			-- 			},
			-- 			label = { width = { fill = false } }, -- default is true
			-- 			label_description = { width = { fill = true } },
			-- 			kind_icon = { width = { fill = false } },
			-- 		},
			-- 	},
			-- },
			-- },
		},
	},
}
