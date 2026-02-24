---@diagnostic disable: no-unknown
local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

---@class opts
---@field buf integer
---@field win integer
---@return table

local function get_win_config()
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.9)

	-- get position to the center of the window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	---@type vim.api.keyset.win_config
	return {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		-- border = "rounded",
	}
end

local function disable_keybindings(bufnr)
	local group = vim.api.nvim_create_augroup("FloaterminalDisableKeybindings", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		buffer = bufnr,
		callback = function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			local modes_to_disable = { "n", "i", "v", "t" }

			local keys_to_disable = {
				"<C-h>",
				"<C-j>",
				"<C-k>",
				"<C-l>",
			}

			for _, mode in ipairs(modes_to_disable) do
				for _, key in ipairs(keys_to_disable) do
					vim.api.nvim_buf_set_keymap(bufnr, mode, key, key, { noremap = true, silent = true })
				end
			end
		end,
		once = true,
	})
end

local function configure_buffer(bufnr)
	local group = vim.api.nvim_create_augroup("FloaterminalConfigureBuffer", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		buffer = bufnr,
		callback = function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			vim.bo[bufnr].buflisted = false
		end,
	})
end

local function handle_resize(win)
	local group = vim.api.nvim_create_augroup("FloaterminalResize", { clear = true })

	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = function()
			if not vim.api.nvim_win_is_valid(win) then
				return
			end

			vim.api.nvim_win_set_config(win, get_win_config())
		end,
	})
end

local function configure_window(win)
	local group = vim.api.nvim_create_augroup("FloaterminalConfigureWindow", { clear = true })

	vim.api.nvim_create_autocmd("TermEnter", {
		group = group,
		callback = function()
			if not vim.api.nvim_win_is_valid(win) then
				return
			end

			vim.wo[win].wrap = true
			vim.wo[win].linebreak = true
		end,
	})
end

local function create_floating_terminal_window(opts)
	opts = opts or {}

	--- @type integer
	local buf = nil

	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	end

	disable_keybindings(buf)
	configure_buffer(buf)

	local win = vim.api.nvim_open_win(buf, true, get_win_config())
	handle_resize(win)

	return { buf = buf, win = win }
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_terminal_window({ buf = state.floating.buf })
		configure_window(state.floating.win)

		-- set buftype to terminal if it isn't one
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.term()
			-- :term creates a new buffer; update state to track it and hide it
			state.floating.buf = vim.api.nvim_win_get_buf(state.floating.win)
			vim.bo[state.floating.buf].buflisted = false
		end

		vim.cmd.startinsert()
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})

-- toggle floaterminal
local toggle_keys = { "<C-/>", "<C-_>" }
for _, key in pairs(toggle_keys) do
	vim.keymap.set({ "n", "i" }, key, "<cmd>Floaterminal<cr>", { desc = "Toggle Floaterminal" })
end
