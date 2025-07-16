-- Keyword local adalah untuk variabel seperti const pada javascript

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.colors = {
	foreground = "#DAD7CD",
	background = "#212121", -- Ubah background menjadi #212121
	cursor_bg = "#47FF9C",
	cursor_border = "#47FF9C",
	cursor_fg = "#011423",
	selection_bg = "#706B4E",
	selection_fg = "#F3D9C4",
	ansi = { "#214969", "#F07178", "#C3E88D", "#FFE073", "#6B6B6B", "#DAD7CD", "#E0E1DD", "#89DDFF" },
	brights = { "#6B6B6B", "#F07178", "#C3E88D", "#FFE073", "#C792E9", "#9F86C0", "#E0E1DD", "#89DDFF" },
}

-- config.color_scheme = 'Colorful Colors (terminal.sexy)'

-- ### Config font ###
-- Alternative font: Geist Mono/Fira Code/JetBrains Mono/MonoLisa/MesloLGS Nerd Font Mono/Maple Mono/Cartograph CF
config.font = wezterm.font("Dank Mono")
config.font_size = 16.5

-- https://wezfurlong.org/wezterm/config/lua/config/underline_thickness.html#underline_thickness
config.underline_thickness = 2.8

config.max_fps = 120

-- ### Config window ###
config.window_background_opacity = 0.8
config.macos_window_background_blur = 8
config.window_decorations = "RESIZE"
config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled
	-- with wezterm.
	-- Whatever font is selected here, it will have the
	-- main font setting appended to it to pick up any
	-- fallback fonts you may have used there.

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 14.5,

	-- The overall background color of the tab bar when
	-- the window is focused
	active_titlebar_bg = "rgba(0,0,0,0)",

	-- The overall background color of the tab bar when
	-- the window is not focused
	inactive_titlebar_bg = "rgba(0,0,0,0)",
}

-- ### Config tab bar ###
-- config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.

-- The filled in variant of the < symbol

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "rgba(0,0,0,0)"
	local background = "#5D9AC0"
	local foreground = "#000"
	local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
	local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

	if tab.is_active then
		background = "#F1BB67"
		foreground = "#000"
		edge_background = "rgba(0,0,0,0)"
		SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
		-- elseif hover then
		--   background = '#3b3052'
		--   foreground = '#909090'
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 1)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

-- ### Window Close Confirmation ###
config.window_close_confirmation = "AlwaysPrompt"

-- ### Keys Config ###
config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.Nop,
	},
}

-- and finally, return the configuration to wezterm
return config
