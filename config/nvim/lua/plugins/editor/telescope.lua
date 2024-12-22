local lsp_symbols = require("ts.config.lsp_symbols")

---@diagnostic disable: no-unknown
local function telescope_buffer_dir()
	return vim.fn.expand("%:p:h")
end

local cwd = function()
	return vim.uv.cwd()
end

local get_visual_selection = function()
	vim.cmd('noautocmd normal! "vy')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})

	text = text:gsub("\n", "")
	if #text > 0 then
		return text
	else
		return ""
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},

			-- necessary for select menus like lsp code actions
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },

			{
				"nvim-telescope/telescope-file-browser.nvim",
				dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
			},
		},

		keys = function()
			local multigrep = require("ts.utils.telescope.multigrep")
			local builtin = require("telescope.builtin")

			local find_files = function()
				builtin.find_files({ cwd = cwd() })
			end

			local find_recent_files = function()
				builtin.oldfiles({ cwd = cwd() })
			end

			local find_config_files = function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end

			return {
				{
					"<leader>,",
					"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
					desc = "Switch Buffer",
				},

				{
					"<leader>:",
					"<cmd>Telescope command_history<cr>",
					desc = "Command History",
				},
				{
					"<leader><space>",
					find_files,
					desc = "Find Files",
				},

				-- find
				{ "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
				{ "<leader>fc", find_config_files, desc = "Find Config File" },
				{ "<leader>ff", find_files, desc = "Find Files" },
				{ "<leader>fr", find_recent_files, desc = "Recent Files (cwd)" },

				-- git
				{ "<leader>gc", builtin.git_commits, desc = "commits" },
				{ "<leader>gs", builtin.git_status, desc = "status" },

				-- search
				{ '<leader>s"', builtin.registers, desc = "Registers" },
				{ "<leader>sa", builtin.autocommands, desc = "Auto Commands" },
				{ "<leader>sb", builtin.current_buffer_fuzzy_find, desc = "Buffer" },
				{ "<leader>sc", builtin.command_history, desc = "Command History" },
				{ "<leader>sC", builtin.commands, desc = "Commands" },
				{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
				{ "<leader>sD", builtin.diagnostics, desc = "Workspace diagnostics" },
				{ "<leader>sh", builtin.help_tags, desc = "Help Pages" },
				{ "<leader>sH", builtin.highlights, desc = "Search Highlight Groups" },
				{ "<leader>sk", builtin.keymaps, desc = "Key Maps" },
				{ "<leader>sM", builtin.man_pages, desc = "Man Pages" },
				{ "<leader>sm", builtin.marks, desc = "Jump to Mark" },
				{ "<leader>so", builtin.vim_options, desc = "Options" },

				{ "<leader>/", multigrep, desc = "MultiGrep" },
				{ "<leader>sw", "<cmd>Telescope grep_string word_match=-w<cr>", desc = "Word" },
				{
					"<leader>sw",
					function()
						local text = get_visual_selection()
						builtin.grep_string({ search = text })
					end,
					mode = "v",
					desc = "Selection",
				},

				{
					"<leader>uC",
					"<cmd>Telescope colorscheme enable_preview=true<cr>",
					desc = "Colorscheme with preview",
				},
				{
					"<leader>ss",
					function()
						require("telescope.builtin").lsp_document_symbols({
							symbols = lsp_symbols,
						})
					end,
					desc = "Goto Symbol",
				},
				{
					"<leader>sS",
					function()
						require("telescope.builtin").lsp_dynamic_workspace_symbols({
							symbols = lsp_symbols,
						})
					end,
					desc = "Goto Symbol (Workspace)",
				},

				{
					"<leader>e",
					function()
						local telescope = require("telescope")
						telescope.extensions.file_browser.file_browser({
							path = "%:p:h",
							cwd = telescope_buffer_dir(),
							respect_gitignore = false,
							-- hidden = true,
							grouped = true,
							-- previewer = false,
							-- initial_mode = "normal",
							layout_config = { height = 40 },
						})
					end,
					desc = "Open File Browser with the path of the current buffer",
				},

				{
					"<leader>fP",
					function()
						require("telescope.builtin").find_files({
							---@diagnostic disable-next-line: param-type-mismatch
							cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
						})
					end,
					desc = "Find Plugin File",
				},

				{
					"<leader>;f",
					function()
						local builtin = require("telescope.builtin")
						builtin.find_files({
							no_ignore = false,
							hidden = true,
						})
					end,
					desc = "Lists files in your current working directory, respects .gitignore",
				},

				{
					"<leader>;b",
					function()
						local builtin = require("telescope.builtin")
						builtin.buffers()
					end,
					desc = "Lists open buffers",
				},

				{
					"<leader>;t",
					function()
						local builtin = require("telescope.builtin")
						builtin.help_tags()
					end,
					desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
				},

				{
					"<leader>;;",
					function()
						local builtin = require("telescope.builtin")
						builtin.resume()
					end,
					desc = "Resume the previous telescope picker",
				},

				{
					"<leader>;e",
					function()
						local builtin = require("telescope.builtin")
						builtin.diagnostics()
					end,
					desc = "Lists Diagnostics for all open buffers or a specific buffer",
				},

				{
					"<leader>;s",
					function()
						local builtin = require("telescope.builtin")
						builtin.treesitter()
					end,
					desc = "Lists Function names, variables, from Treesitter",
				},
			}
		end,

		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = require("telescope").extensions.file_browser.actions

			opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
				wrap_results = true,
				layout_strategy = "vertical", -- :h telescope.layout
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				winblend = 0,
				mappings = {
					n = {},
				},
			})

			opts.pickers = {
				-- find_files = {
				--   theme = "ivy",
				-- },
				-- live_grep = {
				--   theme = "ivy",
				-- },
				-- grep_string = {
				--   theme = "ivy",
				-- },
				diagnostics = {
					-- theme = "ivy",
					initial_mode = "normal",
					layout_config = {
						-- preview_cutoff = 9999,
					},
				},
			}

			opts.extensions = {
				fzf = {},

				file_browser = {
					-- theme = "dropdown",
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
					mappings = {
						["n"] = {
							-- your custom normal mode mappings
							["N"] = fb_actions.create,
							["H"] = fb_actions.goto_parent_dir,
							["h"] = fb_actions.toggle_hidden,
							["/"] = function()
								vim.cmd("startinsert")
							end,
							["<C-u>"] = function(prompt_bufnr)
								for _i = 1, 10 do
									actions.move_selection_previous(prompt_bufnr)
								end
							end,
							["<C-d>"] = function(prompt_bufnr)
								for _i = 1, 10 do
									actions.move_selection_next(prompt_bufnr)
								end
							end,
							["<PageUp>"] = actions.preview_scrolling_up,
							["<PageDown>"] = actions.preview_scrolling_down,
						},
					},
				},

				["ui-select"] = {
					require("telescope.themes").get_dropdown({}),
				},
			}

			telescope.setup(opts)

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension("file_browser"))
		end,
	},
}
