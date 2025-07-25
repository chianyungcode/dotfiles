-- return {
-- 	"iamcco/markdown-preview.nvim",
-- 	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
-- 	ft = { "markdown" },
-- 	build = function()
-- 		vim.fn["mkdp#util#install"]()
-- 	end,
-- }

if true then
	return {}
end

return {
	"brianhuster/live-preview.nvim",
	dependencies = {
		-- You can choose one of the following pickers
		"folke/snacks.nvim",
	},
}
