-- Options are automatically loaded before lazy.nstartup
-- Default options that are always set: https://github.com/LazyLazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- add undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- add file path to top right, useful for multiple splits
-- this uses the usual statusline item syntax ':h statusline' for hints
-- opt.winbar = "%= %m %f " -- yes there's a trailing space
opt.winbar = "%m %f" -- top right

opt.guicursor = ""

opt.nu = true
opt.relativenumber = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.smartindent = true
opt.foldmethod = "indent"

opt.wrap = true

opt.swapfile = false
opt.backup = false
---@diagnostic disable-next-line: assign-type-mismatch
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.hlsearch = false
opt.incsearch = true

-- show highlight previews in split buffer
opt.inccommand = "split"

opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

opt.updatetime = 50

opt.colorcolumn = "80"
