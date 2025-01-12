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

local function create_floating_terminal_window(opts)
	opts = opts or {}

	--- @type integer
	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	end

	local win = vim.api.nvim_open_win(buf, true, get_win_config())

	vim.api.nvim_create_autocmd("VimResized", {
		group = vim.api.nvim_create_augroup("floaterminal-resized", {}),
		callback = function()
			if not vim.api.nvim_win_is_valid(state.floating.win) then
				return
			end

			vim.api.nvim_win_set_config(state.floating.win, get_win_config())
		end,
	})

	return { buf = buf, win = win }
end

local function toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_terminal_window({ buf = state.floating.buf })

		-- set buftype to terminal if it isn't one
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.term()
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
