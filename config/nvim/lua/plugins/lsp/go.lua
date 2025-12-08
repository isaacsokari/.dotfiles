return {

	{
		"neovim/nvim-lspconfig",
		opts = {

			servers = {
				gopls = {
					settings = {
						gopls = {
							codelenses = {
								generate = true, -- Don't show the `go generate` lens.
								gc_details = true, -- Show a code lens toggling the display of gc's choices.
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},

							-- disable adding placeholders to completion
							usePlaceholders = false,

							completeUnimported = true,
							staticcheck = true,
							directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
							semanticTokens = true,

							hints = {
								-- @see https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
								assignVariableTypes = false,
								compositeLiteralFields = true,
								compositeLiteralTypes = false,
								constantValues = true,
								functionTypeParameters = false,
								parameterNames = true,
								rangeVariableTypes = true,
							},

							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
						},
					},
				},
			},

			setup = {
				gopls = function(_, opts)
					-- workaround for gopls not supporting semanticTokensProvider
					-- https://github.com/golang/go/issues/54531#issuecomment-1464982242
					vim.lsp.on_attach(function(client, _)
						if not client.server_capabilities.semanticTokensProvider then
							local semantic = client.config.capabilities.textDocument.semanticTokens
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = {
									tokenTypes = semantic.tokenTypes,
									tokenModifiers = semantic.tokenModifiers,
								},
								range = true,
							}
						end
					end, "gopls")
					-- end workaround
				end,
			},
		},
	},

	-- formatting
	{
		"stevearc/conform.nvim",
		optional = true,

		opts = function(_, opts)
			local formatters = { "goimports", "gofumpt", stop_after_first = true }
			local supported_fts = {
				"go",
				"gomod",
				"gosum",
			}

			opts.formatters_by_ft = opts.formatters_by_ft or {}

			for _, ft in ipairs(supported_fts) do
				---@diagnostic disable-next-line: no-unknown
				opts.formatters_by_ft[ft] = formatters
			end
		end,
	},
}
