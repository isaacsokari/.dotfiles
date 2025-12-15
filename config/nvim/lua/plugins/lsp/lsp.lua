local common_utils = require("ts.utils.common")

return {
	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },

				-- for plugins
				{ path = "snacks.nvim", words = { "Snacks" } },
				{ path = "lazy.nvim", words = { "Lazy" } },
			},
		},

		keys = {},
	},

	{ "Bilal2453/luvit-meta", lazy = true },

	-- Main LSP Configuration
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{
				-- NOTE: Must be loaded before dependants
				"williamboman/mason.nvim",
				config = true,
				keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
			},
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			"hrsh7th/cmp-nvim-lsp",
		},

		opts = {

			-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
			-- Be aware that you also will need to properly configure your LSP server to
			-- provide the inlay hints.
			inlay_hints = {
				enabled = true,

				-- filetypes for which you don't want to enable inlay hints
				exclude = {},
			},

			-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
			-- Be aware that you also will need to properly configure your LSP server to
			-- provide the code lenses.
			codelens = {
				enabled = false,
			},

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			servers = {
				cssls = {},

				html = {},

				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
						},
					},
				},
			},

			setup = {},
		},

		config = function(_, opts)
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("<leader>cl", "<cmd>LspInfo<cr>", "[L]sp Info")
					map("<leader>cL", "<cmd>LspRestart<cr>", "Restart LSPs")

					---@diagnostic disable-next-line: no-unknown
					local telescope_builtin = require("telescope.builtin")

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", telescope_builtin.lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("grr", telescope_builtin.lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", telescope_builtin.lsp_implementations, "[G]oto [I]mplementation")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					-- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("gy", function()
						telescope_builtin.lsp_type_definitions({ reuse_win = true })
					end, "[G]oto T[y]pe Definition")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})

						if common_utils.has("snacks") and Snacks.words.is_enabled() then
							map("]]", function()
								Snacks.words.jump(vim.v.count1)
							end, "Next Reference")

							map("[[", function()
								Snacks.words.jump(-vim.v.count1)
							end, "Prev Reference")

							map("<a-n>", function()
								Snacks.words.jump(vim.v.count1, true)
							end, "Next Reference")

							map("<a-p>", function()
								Snacks.words.jump(-vim.v.count1, true)
							end, "Prev Reference")
						end
					end

					-- this is managed by snacks.nvim
					-- if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					-- 	map("<leader>uh", function()
					-- 		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					-- 	end, "Toggle Inlay [H]ints")
					-- end

					if client and common_utils.has("snacks") then
						local hasWillRename = client.supports_method(vim.lsp.protocol.Methods.workspace_willRenameFiles)
						local hasDidRename = client.supports_method(vim.lsp.protocol.Methods.workspace_didRenameFiles)

						if hasWillRename or hasDidRename then
							map("<leader>cR", function()
								Snacks.rename.rename_file()
							end, "Rename File", "n")
						end
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
						map("<leader>cc", vim.lsp.codelens.run, "Run Codelens", { "n", "v" })
						map("<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens", { "n" })
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_signatureHelp) then
						map("gK", function()
							return vim.lsp.buf.signature_help()
						end, "Signature Help")

						map("<c-k>", function()
							return vim.lsp.buf.signature_help()
						end, "Signature Help", "i")
					end
				end,
			})

			-- to change diagnostic symbols in the sign column (gutter)
			-- see :help diagnostic-signs

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- get servers from opts
			local servers = opts.servers or {}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			---@diagnostic disable-next-line: missing-fields
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
