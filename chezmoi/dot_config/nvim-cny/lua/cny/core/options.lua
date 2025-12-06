local opt = vim.opt

-- netrw
vim.g.loaded_netrw = 0 -- disable default netrw loader
vim.g.loaded_netrwPlugin = 0 -- disable netrw plugin
vim.cmd("let g:netrw_liststyle = 3") -- use tree view in netrw
vim.cmd("let g:netrw_banner = 0") -- hide netrw banner

-- line number
opt.nu = true -- show absolute line numbers
opt.relativenumber = true -- show relative line numbers

-- indentation
opt.tabstop = 4 -- tabs display as 4 spaces
opt.softtabstop = 4 -- editing uses 4-space tabs
opt.shiftwidth = 4 -- indent operations use 4 spaces
opt.expandtab = true -- convert tabs to spaces
opt.smartindent = true -- smart autoindent
opt.wrap = false -- disable line wrapping

-- backup and undo
opt.swapfile = false -- disable swap files
opt.backup = false -- disable backups
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- set undo directory
opt.undofile = true -- persist undo history

-- search
opt.inccommand = "split" -- show substitute previews in split

-- UI
-- opt.background = "dark" -- prefer dark background
opt.scrolloff = 8 -- keep 8 lines of context
opt.signcolumn = "yes" -- always show sign column

-- folding (for nvim-ufo)
opt.foldenable = true -- enable folding
opt.foldmethod = "manual" -- manual fold method
opt.foldlevel = 99 -- keep folds open by default
opt.foldcolumn = "0" -- hide fold column gutter

-- window splits
opt.splitright = true -- new splits go right
opt.splitbelow = true -- new splits go below

-- misc
opt.guicursor = "" -- block cursor everywhere
opt.isfname:append("@-@") -- allow @-@ in file names
opt.updatetime = 50 -- faster cursorhold update
opt.colorcolumn = "80" -- highlight column 80
opt.clipboard:append("unnamedplus") -- use system clipboard
opt.mouse = "a" -- enable mouse everywhere
