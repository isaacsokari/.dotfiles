local common_utils = require("ts.utils.common")
local notify = require("ts.utils.notify")
local treesitter_utils = require("ts.utils.treesitter")

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false, -- last release is way too old and doesn't work on Windows

		opts_extend = { "ensure_installed" },

		---@alias TSFeat { enable?: boolean, disable?: string[] }
		---@class TSConfig
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},

			---@type TSFeat
			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { "ruby" },
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_decremental = "<bs>",
					node_incremental = "<C-space>",
					scope_incremental = false,
				},
			},

			---@type TSFeat
			indent = {
				enable = true,
				disable = { "ruby" },
			},

			textobjects = {
				move = {
					enable = true,
					goto_next_end = {
						["]A"] = "@parameter.inner",
						["]C"] = "@class.outer",
						["]F"] = "@function.outer",
					},
					goto_next_start = {
						["]a"] = "@parameter.inner",
						["]c"] = "@class.outer",
						["]f"] = "@function.outer",
					},
					goto_previous_end = {
						["[A"] = "@parameter.inner",
						["[C"] = "@class.outer",
						["[F"] = "@function.outer",
					},
					goto_previous_start = {
						["[a"] = "@parameter.inner",
						["[c"] = "@class.outer",
						["[f"] = "@function.outer",
					},
				},
			},
		},

		---@param opts TSConfig
		config = function(_, opts)
			local TS = require("nvim-treesitter")

			setmetatable(require("nvim-treesitter.install"), {
				__newindex = function(_, k)
					if k == "compilers" then
						vim.schedule(function()
							notify.error({
								"Setting custom compilers for `nvim-treesitter` is no longer supported.",
								"",
								"For more info, see:",
								"- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
							})
						end)
					end
				end,
			})

			-- some quick sanity checks
			if not TS.get_installed then
				return notify.error("Please use `:Lazy` and update `nvim-treesitter`")
			elseif type(opts.ensure_installed) ~= "table" then
				return notify.error("`nvim-treesitter` opts.ensure_installed must be a table")
			end

			-- setup treesitter
			TS.setup(opts)
			treesitter_utils.get_installed(true) -- initialize the installed langs

			-- install missing parsers
			local install = vim.tbl_filter(function(lang)
				return not treesitter_utils.have(lang)
			end, opts.ensure_installed or {})
			if #install > 0 then
				treesitter_utils.build(function()
					TS.install(install, { summary = true }):await(function()
						treesitter_utils.get_installed(true) -- refresh the installed langs
					end)
				end)
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ts_treesitter", { clear = true }),
				callback = function(ev)
					local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
					if not treesitter_utils.have(ft) then
						return
					end

					---@param feat string
					---@param query string
					local function enabled(feat, query)
						local f = opts[feat] or {} ---@type TSFeat
						return f.enable ~= false
							and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
							and treesitter_utils.have(ft, query)
					end

					-- highlighting
					if enabled("highlight", "highlights") then
						pcall(vim.treesitter.start, ev.buf)
					end

					-- indents
					if enabled("indent", "indents") then
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end

					-- folds
					if enabled("folds", "folds") then
						vim.wo.foldmethod = "expr"
						vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end
				end,
			})
		end,
	},

	-- treesitter playground
	{ "nvim-treesitter/playground", lazy = true },

	-- nvim-treesitter-context
	{
		"nvim-treesitter/nvim-treesitter-context",

		opts = {
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = true,
			multiline_threshold = 20, -- Maximum number of lines to show for a single context
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
		},
	},

	-- treesitter textobjects
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		enabled = true,

		opts = {
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				keys = {
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
			},
		},

		config = function(_, opts)
			local TS = require("nvim-treesitter-textobjects")
			if not TS.setup then
				vim.notify("Please use `:Lazy` and update `nvim-treesitter`", vim.log.levels.ERROR)
				return
			end
			TS.setup(opts)

			local function attach(buf)
				local ft = vim.bo[buf].filetype
				if not (vim.tbl_get(opts, "move", "enable") and treesitter_utils.have(ft, "textobjects")) then
					return
				end
				---@type table<string, table<string, string>>
				local moves = vim.tbl_get(opts, "move", "keys") or {}

				for method, keymaps in pairs(moves) do
					for key, query in pairs(keymaps) do
						local desc = query:gsub("@", ""):gsub("%..*", "")
						desc = desc:sub(1, 1):upper() .. desc:sub(2)
						desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
						desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
						if not (vim.wo.diff and key:find("[cC]")) then
							vim.keymap.set({ "n", "x", "o" }, key, function()
								require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
							end, {
								buffer = buf,
								desc = desc,
								silent = true,
							})
						end
					end
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ts_treesitter_textobjects", { clear = true }),
				callback = function(ev)
					attach(ev.buf)
				end,
			})
			vim.tbl_map(attach, vim.api.nvim_list_bufs())
		end,
	},

	-- Automatically add closing tags for HTML and JSX
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},
}
