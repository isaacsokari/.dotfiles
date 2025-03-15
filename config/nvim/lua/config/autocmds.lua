-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

--- Creates an augroup
---@param name string
---@return integer
local function augroup(name)
	return vim.api.nvim_create_augroup("ts_" .. name, { clear = true })
end

-- fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("conceallevel"),
	pattern = { "json", "jsonc", "markdown" },
	callback = function()
		vim.wo.spell = false
		vim.wo.conceallevel = 0
	end,
})

-- add svg paste keymap for necessary filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("svg_paste"),
	pattern = {
		"svg",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"markdown",
	},

	callback = function()
		vim.keymap.set(
			{ "n", "v" },
			"<leader>vs",
			[[Vpf>i<space>aria-hidden="true"<Esc>$]],
			{ buffer = 0, desc = "Paste SVG (Replace Line)" }
		)
	end,
})

local is_env_file = function(e)
	local start_idx, _ = string.find(e.file, ".env", 1, true)
	return (start_idx or 0) == 1
end

vim.api.nvim_create_autocmd({ "BufNew", "BufNewFile" }, {
	group = augroup("disable_env_diagnostics_buf"),
	pattern = "*",
	callback = function(e)
		if is_env_file(e) then
			vim.bo[e.buf].filetype = "sh"
			vim.diagnostic.enable(false, { bufnr = e.buf })
		end
	end,
})

-- disable diagnostics
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("disable_env_diagnostics_ft"),
	pattern = "sh",
	callback = function(e)
		if is_env_file(e) then
			vim.diagnostic.enable(false, { bufnr = e.buf })
		end
	end,
})

-- disable autoformat in templ buffers
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("disable_autoformat_templ"),
	pattern = "templ",
	callback = function(e)
		---@diagnostic disable-next-line: no-unknown
		vim.b[e.buf].autoformat = false
	end,
})

local function lv_augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = lv_augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = lv_augroup("highlight_yank"),
	callback = function()
		--  See `:help vim.highlight.on_yank()`
		vim.highlight.on_yank()
		-- (vim.hl or vim.highlight).on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = lv_augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = lv_augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = lv_augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = lv_augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = lv_augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = lv_augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = lv_augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- set all yaml file types
vim.api.nvim_create_autocmd({ "BufRead", "BufNew", "BufNewFile" }, {
	pattern = { "*.yaml", "*.yml" },
	callback = function()
		vim.bo.filetype = "yaml"
	end,
	group = augroup("filetype_yaml"),
})
