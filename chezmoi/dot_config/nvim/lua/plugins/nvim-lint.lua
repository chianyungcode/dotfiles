-- https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file
-- https://github.com/DavidAnson/markdownlint-cli2

return {
	"mfussenegger/nvim-lint",
	optional = true,
	opts = {
		linters = {
			-- https://github.com/LazyVim/LazyVim/discussions/4094#discussioncomment-10178217
			["markdownlint-cli2"] = {
				args = { "--config", os.getenv("HOME") .. ".dotfiles/.markdownlint.yaml", "--" },
			},
		},
	},
}
