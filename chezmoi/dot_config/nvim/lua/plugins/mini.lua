return {
	{
		-- Ini hanya untuk tambahan custom options saja, untuk defaultnya diinstall via LazyExtras di file lazy.lua
		"echasnovski/mini.files",
		enabled = true,
		version = false,
		-- keys = {
		-- 	-- Buatan sendiri
		-- 	{
		-- 		"<leader>fm",
		-- 		function()
		-- 			require("mini.files").open(vim.api.nvim_buf_get_name(0))
		-- 		end,
		-- 		desc = "Open mini files",
		-- 	},
		-- },
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
				width_focus = 30,
				-- Width of non-focused window
				width_nofocus = 15,
				-- Width of preview window
				width_preview = 75,
			},
		},
	},
}
