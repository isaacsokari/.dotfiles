local icons = require("ts.config.icons")

local nvim_cmp = {
	"hrsh7th/nvim-cmp",
	version = false, -- last release is way too old
	event = "InsertEnter",

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"saadparwaiz1/cmp_luasnip",
	},

	opts = function()
		vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

		local cmp = require("cmp")
		local defaults = require("cmp.config.default")()
		local luasnip = require("luasnip")

		return {
			completion = {
				completeopt = "menu,menuone,noinsert",
			},

			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<S-CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				["<C-CR>"] = function(fallback)
					cmp.abort()
					fallback()
				end,

				["<C-l>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),

				["<C-h>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),

				-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
				--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
			}),

			sources = cmp.config.sources({
				{
					name = "lazydev",
					-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
					group_index = 0,
				},
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "path" },
			}, {
				{ name = "buffer" },
			}),

			formatting = {
				format = function(_, item)
					local lsp_icons = icons.kinds
					if lsp_icons[item.kind] then
						item.kind = lsp_icons[item.kind] .. item.kind
					end
					return item
				end,
			},

			experimental = {
				ghost_text = {
					hl_group = "CmpGhostText",
				},
			},

			sorting = defaults.sorting,
		}
	end,

	---@param opts cmp.ConfigSchema
	config = function(_, opts)
		for _, source in ipairs(opts.sources) do
			source.group_index = source.group_index or 1
		end
		require("cmp").setup(opts)
	end,
}

return nvim_cmp
