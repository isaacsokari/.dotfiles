return {
	{
		-- Snippet engine used by blink.cmp
		"L3MON4D3/LuaSnip",
		build = (not jit.os:find("Windows"))
				and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
			or nil,

		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},

		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		keys = {
			{
				"<tab>",
				function()
					return require("luasnip").expand_or_locally_jumpable() and "<Plug>luasnip-expand-or-jump" or "<tab>"
				end,
				expr = true,
				silent = true,
				mode = { "i", "s" },
			},
			{
				"<s-tab>",
				function()
					return require("luasnip").locally_jumpable(-1) and "<Plug>luasnip-jump-prev" or "<s-tab>"
				end,
				expr = true,
				silent = true,
				mode = { "i", "s" },
			},
			{
				"<c-tab>",
				function()
					if require("luasnip").choice_active() then
						require("luasnip").change_choice(1)
					end
				end,
				mode = { "i", "s" },
			},
		},
	},
}
