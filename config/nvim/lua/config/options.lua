-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- commenting these out to see if i miss them
-- -- add undercurl
-- vim.cmd([[let &t_Cs = "\e[4:3m"]])
-- vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- auto format
vim.g.autoformat = true

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = true

-- root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

local opt = vim.opt

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

opt.autowrite = true -- Enable auto write

opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions

opt.confirm = true -- Confirm to save changes before exiting modified buffer

opt.cursorline = true -- Enable highlighting of the current line

opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}

opt.foldlevel = 99

-- opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.wrap = true -- Enable line wrap

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.mouse = "a" -- Enable mouse mode

opt.ruler = false -- Disable the default ruler

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })

opt.showmode = false -- Dont show mode since we have a statusline

opt.spelllang = { "en" }

opt.splitkeep = "screen"

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- show status column, and replace fold number
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width

-- add file path to top right, useful for multiple splits
-- this uses the usual statusline item syntax ':h statusline' for hints
-- opt.winbar = "%= %m %f " -- yes there's a trailing space
opt.winbar = "%m %f" -- top right

opt.guicursor = ""
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers

opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup

opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2
opt.shiftwidth = 2 -- Size of an indent
opt.shiftround = true -- Round indent

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true -- Don't ignore case with capitals

-- Enable break indent for wrapped lines
opt.breakindent = true

opt.smartindent = true -- Insert indents automatically
opt.foldmethod = "indent"

opt.swapfile = false
opt.backup = false
---@diagnostic disable-next-line: assign-type-mismatch
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Save undo history
opt.undofile = true
opt.undolevels = 1000

opt.hlsearch = false
opt.incsearch = true

-- show substitution previews in split buffer
opt.inccommand = "split"
opt.jumpoptions = "view"

opt.termguicolors = true -- True color support

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10
-- opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.isfname:append("@-@")

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300
opt.updatetime = 50 -- Save swap file and trigger CursorHold

opt.colorcolumn = "100"
