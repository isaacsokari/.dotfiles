-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

---@diagnostic disable-next-line: unused-local
local discipline = require("ts.discipline")
-- discipline.cowboy()

local keymap = vim.keymap
---@diagnostic disable-next-line: unused-local
local opts = { noremap = true, silent = true }

-- unnecessary as it's mapped to <leader>sR
-- keymap.set(
--   "n",
--   "<leader>sx",
--   require("telescope.builtin").resume,
--   { noremap = true, silent = true, desc = "Resume Search" }
-- )

keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open Netrw Explorer" })

-- prevent the terrible accidental ex mode
keymap.set("n", "Q", "<nop>")

-- move lines down/up
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- highlight after indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- delete other buffers without bufferline
-- keymap.set("n", "<leader>bo", "<Cmd>%bd|e#|bd#<CR>", { desc = "Delete All Other Buffers" })

-- keep cursor position afer joining line
keymap.set("n", "J", "mzJ`z")

-- ensure scrolling down/up keeps cursor centered where possible
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "}", "}zz")
keymap.set("n", "{", "{zz")

-- ensure next/prev search jumps keep cursor centered where possible
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- search and replace current word
-- keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap.set("n", "<leader>fs", "<cmd>source %<CR>", { silent = true, desc = "Source Current File" })
keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make File Executable" })
keymap.set("n", "<leader>fy", "<cmd>!echo % | pbcopy<CR>", { silent = true, desc = "Copy Current Filename" })

-- floating terminal
keymap.set("n", "<leader>fT", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })
keymap.set("n", "<leader>ft", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
keymap.set("n", "<c-/>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
keymap.set("n", "<c-_>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "which_key_ignore" })

-- Terminal keymap.setpings
keymap.set("t", "<esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
-- keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
-- keymap.del("t", "<esc><esc>")
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- lazygit
keymap.set("n", "<leader>gG", function()
  Snacks.lazygit({ cwd = Snacks.root.git() })
end, { desc = "Lazygit (Root Dir)" })
keymap.set("n", "<leader>gg", function()
  Snacks.lazygit()
end, { desc = "Lazygit (cwd)" })
keymap.set("n", "<leader>gb", Snacks.git.blame_line, { desc = "Git Blame Line" })

keymap.set("n", "<leader>gf", function()
  local git_path = vim.api.nvim_buf_get_name(0)
  Snacks.lazygit({ args = { "-f", vim.trim(git_path) } })
end, { desc = "Lazygit Current File History" })
