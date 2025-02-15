-- if true then
-- 	return {}
-- end

return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	-- config = function(_, opts)
	-- 	require("obsidian").setup(opts)
	--
	-- 	-- HACK: fix error, disable completion.nvim_cmp option, manually register sources
	-- 	local cmp = require("cmp")
	-- 	cmp.register_source("obsidian", require("cmp_obsidian").new())
	-- 	cmp.register_source("obsidian_new", require("cmp_obsidian_new").new())
	-- 	cmp.register_source("obsidian_tags", require("cmp_obsidian_tags").new())
	-- end,

	opts = {
		workspaces = {
			{
				name = "personal",
				path = "/Users/chianyung/Desktop/vault-obsidian",
			},
		},

		-- Completion settings
		completion = {
			nvim_cmp = true,
		},
		-- notes_subdir = "limbo", -- Subdirectory for notes
		-- new_notes_location = "_encounter", -- Location for new notes
		-- -- Settings for attachments
		-- attachments = {
		-- 	img_folder = "files", -- Folder for image attachments
		-- },
		--
		-- -- Settings for daily notes
		-- daily_notes = {
		-- 	template = "note", -- Template for daily notes
		-- },
		--
		-- -- Key mappings for Obsidian commands
		-- mappings = {
		-- 	-- "Obsidian follow"
		-- 	["<leader>of"] = {
		-- 		action = function()
		-- 			return require("obsidian").util.gf_passthrough()
		-- 		end,
		-- 		opts = { noremap = false, expr = true, buffer = true },
		-- 	},
		-- 	-- Toggle check-boxes "obsidian done"
		-- 	["<leader>od"] = {
		-- 		action = function()
		-- 			return require("obsidian").util.toggle_checkbox()
		-- 		end,
		-- 		opts = { buffer = true },
		-- 	},
		-- 	-- Create a new newsletter issue
		-- 	["<leader>onn"] = {
		-- 		action = function()
		-- 			return require("obsidian").commands.new_note("Newsletter-Issue")
		-- 		end,
		-- 		opts = { buffer = true },
		-- 	},
		-- 	["<leader>ont"] = {
		-- 		action = function()
		-- 			return require("obsidian").util.insert_template("Newsletter-Issue")
		-- 		end,
		-- 		opts = { buffer = true },
		-- 	},
		-- },
		--
		-- -- Function to generate frontmatter for notes
		-- note_frontmatter_func = function(note)
		-- 	-- This is equivalent to the default frontmatter function.
		-- 	local out = { id = note.id, aliases = note.aliases, tags = note.tags }
		--
		-- 	-- `note.metadata` contains any manually added fields in the frontmatter.
		-- 	-- So here we just make sure those fields are kept in the frontmatter.
		-- 	if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
		-- 		for k, v in pairs(note.metadata) do
		-- 			out[k] = v
		-- 		end
		-- 	end
		-- 	return out
		-- end,
		--
		-- -- Function to generate note IDs
		-- note_id_func = function(title)
		-- 	-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
		-- 	-- In this case a note with the title 'My new note' will be given an ID that looks
		-- 	-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
		-- 	local suffix = ""
		-- 	if title ~= nil then
		-- 		-- If title is given, transform it into valid file name.
		-- 		suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
		-- 	else
		-- 		-- If title is nil, just add 4 random uppercase letters to the suffix.
		-- 		for _ = 1, 4 do
		-- 			suffix = suffix .. string.char(math.random(65, 90))
		-- 		end
		-- 	end
		-- 	return tostring(os.time()) .. "-" .. suffix
		-- end,
		--
		-- -- Settings for templates
		-- templates = {
		-- 	subdir = "templates", -- Subdirectory for templates
		-- 	date_format = "%Y-%m-%d-%a", -- Date format for templates
		-- 	gtime_format = "%H:%M", -- Time format for templates
		-- 	tags = "", -- Default tags for templates
		-- },
	},
}
