local util = require("conform.util")

local function typescript_settings()
	return {
		updateImportsOnFileMove = { enabled = "always" },
		suggest = {
			completeFunctionCalls = false,
		},

		inlayHints = {
			enumMemberValues = { enabled = true },
			functionLikeReturnTypes = { enabled = true },
			parameterNames = { enabled = "literals" }, -- none, literals, all
			parameterTypes = { enabled = true },
			propertyDeclarationTypes = { enabled = true },
			variableTypes = { enabled = false },
		},
	}
end

---@param client vim.lsp.Client
---@param buffer integer
local function on_attach(client, buffer)
	client.commands["_typescript.moveToFileRefactoring"] = function(command)
		---@type string, string, lsp.Range
		local action, uri, range = unpack(command.arguments)

		local function move(new_path)
			client:request("workspace/executeCommand", {
				command = command.command,
				arguments = { action, uri, range, new_path },
			}, nil, buffer)
		end

		local fname = vim.uri_to_fname(uri)
		client:request("workspace/executeCommand", {
			command = "typescript.tsserverRequest",
			arguments = {
				"getMoveToRefactoringFileSuggestions",
				{
					file = fname,
					startLine = range.start.line + 1,
					startOffset = range.start.character + 1,
					endLine = range["end"].line + 1,
					endOffset = range["end"].character + 1,
				},
			},
		}, function(_, result)
			if not (result and result.body and result.body.files) then
				return
			end

			local files = vim.deepcopy(result.body.files)
			table.insert(files, 1, "Enter new path...")
			vim.ui.select(files, {
				prompt = "Select move destination:",
				format_item = function(destination)
					return vim.fn.fnamemodify(destination, ":~:.")
				end,
			}, function(destination)
				if destination and destination:find("^Enter new path") then
					vim.ui.input({
						prompt = "Enter move destination:",
						default = vim.fn.fnamemodify(fname, ":h") .. "/",
						completion = "file",
					}, function(new_path)
						return new_path and move(new_path)
					end)
				elseif destination then
					move(destination)
				end
			end)
		end, buffer)
	end
end

return {

	-- lsp
	{
		"neovim/nvim-lspconfig",
		opts = {

			servers = {
				vtsls = {

					-- explicitly add default filetypes, so that we can extend
					-- them in related extras
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},

					settings = {
						complete_function_calls = false,

						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								completion = {
									enableServerSideFuzzyMatch = true,
								},
							},
						},

						-- Keep JavaScript language preferences in sync with TypeScript.
						typescript = typescript_settings(),
						javascript = typescript_settings(),
					},
					on_attach = on_attach,
				},
			},
		},
	},

	-- formatting
	{

		"stevearc/conform.nvim",
		optional = true,

		opts = function(_, opts)
			local formatters = { "prettierd", "prettier", "biome", stop_after_first = true }
			local supported_fts = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			}

			opts.formatters_by_ft = opts.formatters_by_ft or {}

			for _, ft in ipairs(supported_fts) do
				opts.formatters_by_ft[ft] = formatters
			end

			opts.formatters = opts.formatters or {}

			local prettier_configs = {
				".prettierrc",
				".prettierrc.json",
				".prettierrc.yml",
				".prettierrc.yaml",
			}
			local can_use_prettier = function(self, ctx)
				return util.root_file(prettier_configs)(self, ctx) ~= nil
			end

			opts.formatters = vim.tbl_deep_extend("force", opts.formatters, {
				prettierd = { condition = can_use_prettier },
				prettier = { condition = can_use_prettier },
			})
		end,
	},
}
