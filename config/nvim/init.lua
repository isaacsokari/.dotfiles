-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd.colorscheme("catppuccin")

-- require global lua functions
require("ts.globals")

require("ts.snippets")
