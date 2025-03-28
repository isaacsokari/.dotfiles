local lsp_symbols = require("ts.config.lsp_symbols")

---@return {get_fg?:string}?
local function get_fg(name)
	local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
	---@diagnostic disable-next-line: undefined-field
	local fg = hl and hl.fg or hl.foreground
	return fg and { fg = string.format("#%06x", fg) } or nil
end

return {

	-- indent guides for Neovim
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = function()
			---@diagnostic disable-next-line: missing-fields
			require("snacks")
				.toggle({
					name = "Indention Guides",
					get = function()
						return require("ibl.config").get_config(0).enabled
					end,
					set = function(state)
						require("ibl").setup_buffer(0, { enabled = state })
					end,
				})
				:map("<leader>ug")

			return {
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = { show_start = false, show_end = false },
				exclude = {
					filetypes = {
						"Trouble",
						"alpha",
						"dashboard",
						"help",
						"lazy",
						"mason",
						"neo-tree",
						"notify",
						"snacks_dashboard",
						"snacks_notif",
						"snacks_terminal",
						"snacks_win",
						"toggleterm",
						"trouble",
					},
				},
			}
		end,
		main = "ibl",
	},

	-- messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			-- ui components
			{ "MunifTanjim/nui.nvim", lazy = true },
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},
    -- stylua: ignore
    keys = {
      { "<leader>sn",  "",                                                                            desc = "+noice" },
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                 mode = "c",                              desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                                   desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end,                                desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end,                                    desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end,                                desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end,                                   desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>",       function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  silent = true,                           expr = true,              desc = "Scroll Forward",  mode = { "i", "n", "s" } },
      { "<c-b>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true,                           expr = true,              desc = "Scroll Backward", mode = { "i", "n", "s" } },
    },
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},

	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 5000,
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		init = function()
			---@diagnostic disable-next-line: no-unknown
			vim.g.lualine_laststatus = vim.o.laststatus
			---@diagnostic disable-next-line: no-unknown
			if vim.fn.argc(-1) > 0 then
				-- set an empty statusline till lualine loads
				---@diagnostic disable-next-line: no-unknown
				vim.o.statusline = " "
			else
				-- hide the statusline on the starter page
				---@diagnostic disable-next-line: no-unknown
				vim.o.laststatus = 0
			end
		end,
		opts = function()
			-- PERF: we don't need this lualine require madness 🤷
			local lualine_require = require("lualine_require")
			lualine_require.require = require

			vim.o.laststatus = vim.g.lualine_laststatus

			return {
				options = {
					theme = "auto",
					globalstatus = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
					-- disable section separators
					section_separators = "",
					component_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },

					lualine_c = {
						{
							"diagnostics",

							icons_enabled = false, -- disable icons

							-- -- if I wanted icons, I'd have used these
							-- symbols = {
							-- 	error = icons.diagnostics.Error,
							-- 	warn = icons.diagnostics.Warn,
							-- 	info = icons.diagnostics.Info,
							-- 	hint = icons.diagnostics.Hint,
							-- },
						},
					},

					lualine_y = {

            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.command.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = get_fg("Statement"),
            },

            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.mode.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = get_fg("Constant"),
            },

            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = get_fg("Debug"),
            },

						{
							require("lazy.status").updates,
							cond = require("lazy.status").has_updates,
							color = get_fg("Special"),
						},

						{
							"diff",
							symbols = {
								-- added = icons.git.added,
								-- modified = icons.git.modified,
								-- removed = icons.git.removed,

								added = "A:",
								modified = "M:",
								removed = "R:",
							},
							source = function()
								local gitsigns = vim.b.gitsigns_status_dict
								if gitsigns then
									return {
										added = gitsigns.added,
										modified = gitsigns.changed,
										removed = gitsigns.removed,
									}
								end
							end,
						},
					},

					lualine_z = {
						{ "progress", separator = " ", padding = { left = 1, right = 0 } },
						{ "location", padding = { left = 0, right = 1 } },
					},
				},

        -- stylua: ignore
        extensions = { "lazy" },
			}
		end,
	},

	-- icons
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	-- symbol outline
	{
		"hedyhli/outline.nvim",
		keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
		cmd = "Outline",
		opts = function()
			local defaults = require("outline.config").defaults
			local opts = {
				symbols = {
					icons = {},
					filter = vim.deepcopy(lsp_symbols),
				},
				keymaps = {
					up_and_jump = "<up>",
					down_and_jump = "<down>",
				},
			}

			for kind, symbol in pairs(defaults.symbols.icons) do
				local icon_kinds = require("ts.config.icons").kinds
				---@diagnostic disable-next-line: assign-type-mismatch
				icon_kinds[kind] = {
					icon = icon_kinds[kind] or symbol.icon,
					hl = symbol.hl,
				}
			end
			return opts
		end,
	},
}
