local icons = require("ts.config.icons")

local blink_cmp = {
	"saghen/blink.cmp",
	version = "1.*",

	opts = function()
		vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment", default = true })

		return {
			keymap = {
				preset = "none",
				["<C-n>"] = {
					function(cmp)
						return cmp.select_next({ auto_insert = true })
					end,
					"fallback",
				},
				["<C-p>"] = {
					function(cmp)
						return cmp.select_prev({ auto_insert = true })
					end,
					"fallback",
				},
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-Space>"] = { "show" },
				["<C-e>"] = { "cancel", "fallback" },
				["<CR>"] = { "select_and_accept", "fallback" },
				-- Blink uses each source's edit range; it has no per-key insert/replace mode.
				["<S-CR>"] = { "select_and_accept", "fallback" },
				["<C-CR>"] = {
					function(cmp)
						cmp.cancel()
					end,
					"fallback",
				},
				["<C-l>"] = {
					function()
						local luasnip = require("luasnip")
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
							return true
						end
					end,
				},
				["<C-h>"] = {
					function()
						local luasnip = require("luasnip")
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
							return true
						end
					end,
				},
			},

			appearance = {
				kind_icons = icons.kinds,
			},

			completion = {
				accept = {
					auto_brackets = { enabled = false },
				},
				documentation = { auto_show = true },
				ghost_text = { enabled = true },
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
			},

			snippets = { preset = "luasnip" },

			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					lsp = {
						opts = { tailwind_color_icon = "██" },
					},
				},
			},

			cmdline = { enabled = false },
		}
	end,
}

return blink_cmp
