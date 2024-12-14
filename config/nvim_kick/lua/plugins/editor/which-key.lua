return {
	"folke/which-key.nvim",
	event = "VimEnter",
	opts_extend = { "spec" },
	opts = {
		defaults = {},

		-- Document existing key chains
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader><tab>", group = "tabs" },
				{ "<leader>c", group = "code" },
				{ "<leader>f", group = "file/find" },
				{ "<leader>g", group = "git" },
				{ "<leader>gh", group = "hunks" },
				{ "<leader>q", group = "quit/session" },
				{ "<leader>s", group = "search" },
				{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
				{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
				{ "[", group = "prev" },
				{ "]", group = "next" },
				{ "g", group = "goto" },
				{ "gs", group = "surround" },
				{ "z", group = "fold" },
				{
					"<leader>b",
					group = "buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{
					"<leader>w",
					group = "windows",
					proxy = "<c-w>",
					expand = function()
						return require("which-key.extras").expand.win()
					end,
				},

				-- better descriptions
				{ "gx", desc = "Open with system app" },
			},
		},
	},
	-- set icon mappings to true if you have a Nerd Font
	mappings = vim.g.have_nerd_font,
	-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
	-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
	keys = vim.g.have_nerd_font and {} or {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Keymaps (which-key)",
		},
		{
			"<c-w><space>",
			function()
				require("which-key").show({ keys = "<c-w>", loop = true })
			end,
			desc = "Window Hydra Mode (which-key)",
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		if not vim.tbl_isempty(opts.defaults) then
			vim.notify("which-key: opts.defaults is deprecated. Please use opts.spec instead.", "warn")
			wk.register(opts.defaults)
		end
	end,
}