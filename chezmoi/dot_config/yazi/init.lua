require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})
require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })
require("starship"):setup()
