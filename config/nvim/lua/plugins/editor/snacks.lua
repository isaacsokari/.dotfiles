local formatting = require("ts.utils.formatting")
local _common_utils = require("ts.utils.common")

-- Terminal Mappings
local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
local function safe_keymap_set(mode, lhs, rhs, opts)
	local keys = require("lazy.core.handler").handlers.keys
	---@cast keys LazyKeysHandler
	local modes = type(mode) == "string" and { mode } or mode

	---@param m string
	modes = vim.tbl_filter(function(m)
		return not (keys.have and keys:have(lhs, m))
	end, modes)

	-- do not create the keymap if a lazy keys handler exists
	if #modes > 0 then
		opts = opts or {}
		opts.silent = opts.silent ~= false
		if opts.remap and not vim.g.vscode then
			---@diagnostic disable-next-line: no-unknown
			opts.remap = nil
		end
		vim.keymap.set(modes, lhs, rhs, opts)
	end
end

return {
	"folke/snacks.nvim",

	opts = {
		bigfile = { enabled = true },

		dashboard = {
			enabled = true,

			preset = {
				-- generated the logo using
				-- https://patorjk.com/software/taag/#p=display&h=0&f=ANSI%20Shadow&t=TS
				header = [[
   ████████╗███████╗
   ╚══██╔══╝██╔════╝
      ██║   ███████╗
      ██║   ╚════██║
      ██║   ███████║
      ╚═╝   ╚══════╝
  ]],

				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles', {cwd = vim.uv.cwd()})",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},

		dim = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		statuscolumn = { enabled = false }, -- i set this in options.lua
		terminal = { enabled = false }, -- i use floaterminal

		toggle = { map = safe_keymap_set },
		words = { enabled = true },
	},

	keys = {
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
	},

	config = function(_, opts)
		local snacks = require("snacks")
		local keymap = vim.keymap

		-- buffer
		keymap.set("n", "<leader>bd", function()
			Snacks.bufdelete()
		end, { desc = "Delete Buffer" })

		keymap.set("n", "<leader>bo", function()
			Snacks.bufdelete.other()
		end, { desc = "Delete Other Buffers" })

		keymap.set("n", "<leader>ba", function()
			Snacks.bufdelete.all()
		end, { desc = "Delete All Buffers" })

		-- lazygit
		if vim.fn.executable("lazygit") == 1 then
			keymap.set("n", "<leader>gG", function()
				---@diagnostic disable-next-line: missing-fields
				snacks.lazygit({ cwd = snacks.git.get_root() })
			end, { desc = "Lazygit (Root Dir)" })

			keymap.set("n", "<leader>gg", function()
				snacks.lazygit()
			end, { desc = "Lazygit (cwd)" })

			keymap.set("n", "<leader>gb", function()
				snacks.git.blame_line()
			end, { desc = "Git Blame Line" })

			keymap.set({ "n", "x" }, "<leader>gB", function()
				Snacks.gitbrowse()
			end, { desc = "Git Browse (open)" })

			keymap.set({ "n", "x" }, "<leader>gY", function()
				---@diagnostic disable-next-line: missing-fields
				Snacks.gitbrowse({
					open = function(url)
						vim.fn.setreg("+", url)
					end,
					notify = false,
				})
			end, { desc = "Git Browse (copy)" })

			keymap.set("n", "<leader>gf", function()
				local git_path = vim.api.nvim_buf_get_name(0)
				---@diagnostic disable-next-line: missing-fields
				snacks.lazygit({ args = { "-f", vim.trim(git_path) } })
			end, { desc = "Lazygit Current File History" })
		end

		-- toggle options
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
		Snacks.toggle.diagnostics():map("<leader>ud")
		Snacks.toggle.line_number():map("<leader>ul")
		Snacks.toggle
			.option(
				"conceallevel",
				{ off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }
			)
			:map("<leader>uc")
		Snacks.toggle
			.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
			:map("<leader>uA")
		Snacks.toggle.treesitter():map("<leader>uT")
		Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")

		Snacks.toggle.dim():map("<leader>uD")

		if vim.lsp.inlay_hint then
			Snacks.toggle.inlay_hints():map("<leader>uh")
		end

		formatting.snacks_toggle():map("<leader>uf")
		formatting.snacks_toggle(true):map("<leader>uF")

		local success, tsc = pcall(require, "treesitter-context")
		if success then
			Snacks.toggle({
				name = "Treesitter Context",
				get = tsc.enabled,
				set = function(state)
					if state then
						tsc.enable()
					else
						tsc.disable()
					end
				end,
			}):map("<leader>ut")
		end

		snacks.setup(opts)
	end,
}
