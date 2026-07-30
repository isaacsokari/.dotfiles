return {
	{
		"catppuccin/nvim",
		priority = 1000,
		-- lazy = true,
		name = "catppuccin",
		opts = {
			integrations = {
				blink_cmp = { style = "bordered" },
				grug_far = true,
				gitsigns = true,
				lsp_trouble = true,
				mason = true,
				markdown = true,
				mini = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				neotest = true,
				noice = true,
				semantic_tokens = true,
				snacks = true,
				telescope = true,
				treesitter = true,
				treesitter_context = true,
				which_key = true,
			},
		},

		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
			vim.api.nvim_set_hl(0, "Folded", { link = "FoldColumn" })
		end,
	},
}
