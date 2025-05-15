-- if true then
-- return {}
-- end
-- Uncomment this line above if want to active this plugin

return {
	{
		"rmagatti/auto-session",
		enabled = true,
		lazy = false,

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = 'debug',
		},
	},
}
